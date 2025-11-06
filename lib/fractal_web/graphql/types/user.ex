defmodule FractalWeb.GraphQL.Types.User do
  @moduledoc """
  Tipo GraphQL para Usuario.
  """
  use Absinthe.Schema.Notation

  @desc "Usuario del sistema"
  object :user do
    field :id, non_null(:id), description: "ID único del usuario"
    field :email, non_null(:string), description: "Email del usuario"
    field :first_name, non_null(:string), description: "Nombre del usuario"
    field :last_name, non_null(:string), description: "Apellido del usuario"
    field :role, non_null(:user_role), description: "Rol del usuario en el sistema"
    field :inserted_at, non_null(:string), description: "Fecha de creación"
    field :updated_at, non_null(:string), description: "Fecha de última actualización"
  end

  @desc "Rol de usuario"
  enum :user_role do
    value(:student, description: "Estudiante")
    value(:admin, description: "Administrador")
  end
end
