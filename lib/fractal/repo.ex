defmodule Fractal.Repo do
  use Ecto.Repo,
    otp_app: :fractal,
    adapter: Ecto.Adapters.MyXQL
end
