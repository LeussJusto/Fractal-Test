defmodule Fractal.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FractalWeb.Telemetry,
      Fractal.Repo,
      {DNSCluster, query: Application.get_env(:fractal, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Fractal.PubSub},
      # Conexión a Valkey
      {Redix, host: System.get_env("REDIS_HOST", "valkey"), port: 6379, name: :redix},
      # GenServer
      Fractal.Courses.GenServers.CourseSlotManager,
      FractalWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Fractal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    FractalWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
