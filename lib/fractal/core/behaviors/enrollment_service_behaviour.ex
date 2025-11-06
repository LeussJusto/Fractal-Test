defmodule Fractal.Core.Behaviors.EnrollmentServiceBehaviour do
  @moduledoc """
  Behaviour para el servicio de inscripciones (EnrollmentService).
  Define la interfaz esperada para operaciones de matrícula.
  """
  @callback list_user_enrollments(user_id :: integer()) :: [map()]
  @callback list_course_enrollments(course_id :: integer()) :: [map()]
  @callback get_enrollment(id :: integer()) :: map() | nil
  @callback create_enrollment(attrs :: map()) :: {:ok, map()} | {:error, term()}
  @callback cancel_enrollment(enrollment :: map()) :: {:ok, map()} | {:error, term()}
  @callback enroll_user(user_id :: integer(), course_id :: integer()) ::
              {:ok, map()} | {:error, term()}
  @callback cancel_enrollment_by_id(enrollment_id :: integer()) :: {:ok, map()} | {:error, term()}
end
