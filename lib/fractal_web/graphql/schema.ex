defmodule FractalWeb.GraphQL.Schema do
  @moduledoc """
  Schema principal de GraphQL.
  Este es el punto de entrada principal que importa y organiza.
  """
  use Absinthe.Schema

  # Importar tipos escalares de Absinthe
  import_types(Absinthe.Type.Custom)

  # Importar todos los types
  import_types(FractalWeb.GraphQL.Types.User)
  import_types(FractalWeb.GraphQL.Types.Auth)
  import_types(FractalWeb.GraphQL.Types.Course)
  import_types(FractalWeb.GraphQL.Types.Enrollment)

  # Importar schemas de dominios
  import_types(FractalWeb.GraphQL.Schema.AuthSchema)
  import_types(FractalWeb.GraphQL.Schema.CourseSchema)
  import_types(FractalWeb.GraphQL.Schema.EnrollmentSchema)

  # Queries principales (agrupa queries de todos los dominios)
  query do
    import_fields(:auth_queries)
    import_fields(:course_queries)
    import_fields(:enrollment_queries)
  end

  # Mutations principales (agrupa mutations de todos los dominios)
  mutation do
    import_fields(:auth_mutations)
    import_fields(:course_mutations)
    import_fields(:enrollment_mutations)
  end

  # Subscriptions (para notificaciones en tiempo real)
  # subscription do
  #   import_fields(:enrollment_subscriptions)
  # end
end
