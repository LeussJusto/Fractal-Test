defmodule FractalWeb.GraphQL.Schema.CourseSchema do
  @moduledoc """
  Schema de cursos.
  Define las queries y mutations relacionadas con cursos.
  """
  use Absinthe.Schema.Notation

  alias FractalWeb.GraphQL.{Resolvers, Middleware}

  object :course_queries do
    @desc "Obtener todos los cursos"
    field :courses, list_of(:course) do
      resolve(&Resolvers.Course.list_courses/3)
    end

    @desc "Obtener cursos con cupos disponibles"
    field :available_courses, list_of(:course) do
      resolve(&Resolvers.Course.list_available_courses/3)
    end

    @desc "Obtener un curso por ID"
    field :course, :course do
      arg(:id, non_null(:id))
      resolve(&Resolvers.Course.get_course/3)
    end

    @desc "Obtener un curso por código"
    field :course_by_code, :course do
      arg(:code, non_null(:string))
      resolve(&Resolvers.Course.get_course_by_code/3)
    end
  end

  object :course_mutations do
    @desc "Crear un nuevo curso (requiere autenticación)"
    field :create_course, :course do
      arg(:name, non_null(:string))
      arg(:code, non_null(:string))
      arg(:description, :string)
      arg(:capacity, non_null(:integer))

      middleware(Middleware.Authenticate)
      resolve(&Resolvers.Course.create_course/3)
    end

    @desc "Actualizar un curso existente (requiere autenticación)"
    field :update_course, :course do
      arg(:id, non_null(:id))
      arg(:name, :string)
      arg(:description, :string)
      arg(:capacity, :integer)
      arg(:available_slots, :integer)

      middleware(Middleware.Authenticate)
      resolve(&Resolvers.Course.update_course/3)
    end

    @desc "Eliminar un curso (requiere autenticación)"
    field :delete_course, :course do
      arg(:id, non_null(:id))

      middleware(Middleware.Authenticate)
      resolve(&Resolvers.Course.delete_course/3)
    end
  end
end
