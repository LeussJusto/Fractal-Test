defmodule FractalWeb.GraphQL.Schema.AuthSchema do
  @moduledoc """
  Schema de autenticación.
  Define las queries y mutations relacionadas con auth.
  """
  use Absinthe.Schema.Notation

  alias FractalWeb.GraphQL.{Resolvers, Middleware}

  object :auth_queries do
    @desc "Obtener el usuario actual autenticado"
    field :me, :user do
      middleware(Middleware.Authenticate)
      resolve(&Resolvers.Auth.me/3)
    end
  end

  object :auth_mutations do
    @desc "Registrar un nuevo usuario"
    field :register, :auth_payload do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))

      resolve(&Resolvers.Auth.register/3)
    end

    @desc "Iniciar sesión"
    field :login, :auth_payload do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&Resolvers.Auth.login/3)
    end
  end
end
