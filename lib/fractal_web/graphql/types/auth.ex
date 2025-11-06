defmodule FractalWeb.GraphQL.Types.Auth do
  @moduledoc """
  Tipos GraphQL para autenticación.
  """
  use Absinthe.Schema.Notation

  @desc "Payload de respuesta de autenticación"
  object :auth_payload do
    field :token, non_null(:string), description: "JWT token de autenticación"
    field :user, non_null(:user), description: "Usuario autenticado"
  end
end
