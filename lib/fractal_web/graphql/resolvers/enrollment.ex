defmodule FractalWeb.GraphQL.Resolvers.Enrollment do
  @moduledoc """
  Resolvers para operaciones de inscripciones (enrollments).
  Maneja queries y mutations relacionadas con inscripciones a cursos.
  """

  alias Fractal.Courses.Services.EnrollmentService
  alias Fractal.Courses.Schemas.Enrollment
  alias Fractal.Repo

  @doc """
  Lista todas las inscripciones (solo para administradores).
  """
  def list_enrollments(_parent, _args, _resolution) do
    enrollments =
      Enrollment
      |> Repo.all()
      |> Repo.preload([:user, :course])

    {:ok, enrollments}
  end

  @doc """
  Lista inscripciones del usuario autenticado.
  """
  def list_my_enrollments(_parent, _args, %{context: %{current_user: user}}) do
    enrollments =
      EnrollmentService.list_user_enrollments(user.id)
      |> Repo.preload([:user, :course])

    {:ok, enrollments}
  end

  @doc """
  Lista inscripciones de un curso específico.
  """
  def list_course_enrollments(_parent, %{course_id: course_id}, _resolution) do
    enrollments =
      EnrollmentService.list_course_enrollments(course_id)
      |> Repo.preload([:user, :course])

    {:ok, enrollments}
  end

  @doc """
  Obtiene una inscripción por ID.
  """
  def get_enrollment(_parent, %{id: id}, _resolution) do
    case EnrollmentService.get_enrollment(id) do
      nil ->
        {:error, message: "Inscripción no encontrada"}

      enrollment ->
        enrollment = Repo.preload(enrollment, [:user, :course])
        {:ok, enrollment}
    end
  end

  @doc """
  Inscribe al usuario autenticado en un curso.
  """
  def enroll_in_course(_parent, %{course_id: course_id}, %{context: %{current_user: user}}) do
    case EnrollmentService.enroll_user(user.id, course_id) do
      {:ok, enrollment} ->
        enrollment = Repo.preload(enrollment, [:user, :course])
        {:ok, enrollment}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, format_changeset_errors(changeset)}

      {:error, :course_full} ->
        {:error, message: "El curso está lleno, no hay cupos disponibles"}

      {:error, :already_enrolled} ->
        {:error, message: "Ya estás inscrito en este curso"}

      {:error, reason} ->
        {:error, message: "Error al inscribirse: #{inspect(reason)}"}
    end
  end

  @doc """
  Cancela una inscripción.
  El usuario solo puede cancelar sus propias inscripciones.
  """
  def cancel_enrollment(_parent, %{enrollment_id: enrollment_id}, %{
        context: %{current_user: user}
      }) do
    case EnrollmentService.get_enrollment(enrollment_id) do
      nil ->
        {:error, message: "Inscripción no encontrada"}

      enrollment ->
        # Verificar que el usuario sea el dueño de la inscripción
        if enrollment.user_id == user.id do
          case EnrollmentService.cancel_enrollment_by_id(enrollment_id) do
            {:ok, cancelled_enrollment} ->
              cancelled_enrollment = Fractal.Repo.preload(cancelled_enrollment, [:user, :course])
              {:ok, cancelled_enrollment}

            {:error, %Ecto.Changeset{} = changeset} ->
              {:error, format_changeset_errors(changeset)}

            {:error, :already_cancelled} ->
              {:error, message: "Esta inscripción ya está cancelada"}

            {:error, reason} ->
              {:error, message: "Error al cancelar inscripción: #{inspect(reason)}"}
          end
        else
          {:error, message: "No tienes permiso para cancelar esta inscripción"}
        end
    end
  end

  # Helpers privados

  defp format_changeset_errors(changeset) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
          opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
        end)
      end)

    %{
      message: "Error de validación",
      details: errors
    }
  end
end
