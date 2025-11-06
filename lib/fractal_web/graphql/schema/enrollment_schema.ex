defmodule FractalWeb.GraphQL.Schema.EnrollmentSchema do
  @moduledoc """
  Schema GraphQL para operaciones de inscripciones (enrollments).
  Define queries y mutations relacionadas con inscripciones a cursos.
  """
  use Absinthe.Schema.Notation

  alias FractalWeb.GraphQL.Resolvers
  alias FractalWeb.GraphQL.Middleware

  object :enrollment_queries do
    @desc "Listar todas las inscripciones (requiere autenticación)"
    field :enrollments, list_of(:enrollment) do
      middleware(Middleware.Authenticate)
      resolve(&Resolvers.Enrollment.list_enrollments/3)
    end

    @desc "Listar inscripciones del usuario autenticado"
    field :my_enrollments, list_of(:enrollment) do
      middleware(Middleware.Authenticate)
      resolve(&Resolvers.Enrollment.list_my_enrollments/3)
    end

    @desc "Listar inscripciones de un curso específico"
    field :course_enrollments, list_of(:enrollment) do
      arg(:course_id, non_null(:id))
      middleware(Middleware.Authenticate)
      resolve(&Resolvers.Enrollment.list_course_enrollments/3)
    end

    @desc "Obtener una inscripción por ID"
    field :enrollment, :enrollment do
      arg(:id, non_null(:id))
      middleware(Middleware.Authenticate)
      resolve(&Resolvers.Enrollment.get_enrollment/3)
    end
  end

  object :enrollment_mutations do
    @desc "Inscribirse a un curso"
    field :enroll_in_course, :enrollment do
      arg(:course_id, non_null(:id))
      middleware(Middleware.Authenticate)
      resolve(&Resolvers.Enrollment.enroll_in_course/3)
    end

    @desc "Cancelar inscripción a un curso"
    field :cancel_enrollment, :enrollment do
      arg(:enrollment_id, non_null(:id))
      middleware(Middleware.Authenticate)
      resolve(&Resolvers.Enrollment.cancel_enrollment/3)
    end
  end
end
