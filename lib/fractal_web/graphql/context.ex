defmodule FractalWeb.GraphQL.Context do
  @moduledoc """
  Plug para construir el contexto de GraphQL.
  """
  @behaviour Plug

  alias Fractal.Accounts.Services.AuthService

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    context = build_context_map(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context_map(conn) do
    case get_token(conn) do
      {:ok, token} ->
        case AuthService.verify_token(token) do
          {:ok, user} ->
            %{current_user: user}

          {:error, _reason} ->
            %{}
        end

      :error ->
        %{}
    end
  end

  # Extrae el token del header Authorization.
  defp get_token(conn) do
    case Plug.Conn.get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      _ -> :error
    end
  end
end
