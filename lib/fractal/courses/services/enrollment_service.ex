defmodule Fractal.Courses.Services.EnrollmentService do
  alias Fractal.Core.Types.EnrollmentStatus
  @behaviour Fractal.Core.Behaviors.EnrollmentServiceBehaviour
  @moduledoc """
  Servicio para operaciones de matrícula.
  Incluye lógica de negocio para verificar disponibilidad y restricciones.
  """

  alias Fractal.Repo
  alias Fractal.Courses.Schemas.Enrollment
  alias Fractal.Notifications.Services.NotificationService
  alias Fractal.Courses.Queries.EnrollmentQueries
  alias Fractal.Courses.Services.CourseService
  alias Fractal.Courses.GenServers.CourseSlotManager

  @doc """
  Lista todas las matrículas de un usuario (con caché de 60s).
  """
  def list_user_enrollments(user_id) do
    cache_key = "user_enrollments_" <> to_string(user_id)

    case Fractal.Cache.get(cache_key) do
      nil ->
        enrollments =
          EnrollmentQueries.by_user(user_id)
          |> EnrollmentQueries.preload_associations()
          |> Repo.all()

        Fractal.Cache.set(cache_key, enrollments, expiry: 60)
        enrollments

      cached ->
        cached
    end
  end

  @doc """
  Lista las matrículas de un curso (con caché de 60s).
  """
  def list_course_enrollments(course_id) do
    cache_key = "course_enrollments_" <> to_string(course_id)

    case Fractal.Cache.get(cache_key) do
      nil ->
        enrollments =
          EnrollmentQueries.by_course(course_id)
          |> EnrollmentQueries.preload_associations()
          |> Repo.all()

        Fractal.Cache.set(cache_key, enrollments, expiry: 60)
        enrollments

      cached ->
        cached
    end
  end

  @doc """
  Obtiene una matrícula por ID.
  """
  def get_enrollment(id) do
    Repo.get(Enrollment, id)
  end

  @doc """
  Crea una matrícula y limpia caché de usuario y curso.
  """
  def create_enrollment(attrs) do
    attrs = Map.update(attrs, :status, EnrollmentStatus.values() |> hd(), fn val -> val end)

    result =
      %Enrollment{}
      |> Enrollment.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, enrollment} ->
        # Invalidar cache relevante
        Fractal.Cache.del("user_enrollments_" <> to_string(enrollment.user_id))
        Fractal.Cache.del("course_enrollments_" <> to_string(enrollment.course_id))
        {:ok, enrollment}

      error ->
        error
    end
  end

  @doc """
  Cancela una matrícula y limpia la caché.
  """
  def cancel_enrollment(%Enrollment{} = enrollment) do
    result =
      enrollment
      |> Enrollment.changeset(%{
        status: :cancelled,
        cancelled_at: DateTime.utc_now()
      })
      |> Repo.update()

    case result do
      {:ok, updated} ->
        # Invalidar cache relevante
        Fractal.Cache.del("user_enrollments_" <> to_string(updated.user_id))
        Fractal.Cache.del("course_enrollments_" <> to_string(updated.course_id))
        {:ok, updated}

      error ->
        error
    end
  end

  @doc """
  Inscribe a un usuario en un curso.
  Verifica disponibilidad y evita duplicados.
  """
  def enroll_user(user_id, course_id) do
    with {:ok, course} <- validate_course_exists(course_id),
         :ok <- validate_not_already_enrolled(user_id, course_id),
         {:ok, :slot_reserved} <- CourseSlotManager.reserve_slot(course_id) do
      enrollment_result = create_enrollment_with_slot_decrement(user_id, course_id, course)
      NotificationService.notify_enrollment_created(user_id, course_id)
      enrollment_result
    else
      {:error, :no_slots} = error -> error
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Cancela la matrícula de un usuario en un curso y libera el cupo.
  """
  def cancel_enrollment_by_id(enrollment_id) do
    with {:ok, enrollment} <- get_enrollment_for_cancellation(enrollment_id),
         {:ok, course} <- CourseService.get_course(enrollment.course_id) |> validate_exists(),
         {:ok, cancelled_enrollment} <- cancel_enrollment_with_slot_increment(enrollment, course),
         {:ok, :slot_released} <- CourseSlotManager.release_slot(enrollment.course_id) do
      NotificationService.notify_enrollment_cancelled(
        cancelled_enrollment.user_id,
        cancelled_enrollment.course_id
      )

      {:ok, cancelled_enrollment}
    end
  end

  # PRIVATE FUNCTIONS

  defp validate_course_exists(course_id) do
    case CourseService.get_course(course_id) do
      nil -> {:error, :course_not_found}
      course -> {:ok, course}
    end
  end

  defp validate_not_already_enrolled(user_id, course_id) do
    exists =
      EnrollmentQueries.exists?(user_id, course_id)
      |> Repo.exists?()

    if exists do
      {:error, :already_enrolled}
    else
      :ok
    end
  end

  defp create_enrollment_with_slot_decrement(user_id, course_id, _course) do
    enrollment_changeset =
      Enrollment.changeset(%Enrollment{}, %{
        user_id: user_id,
        course_id: course_id,
        status: :active,
        enrolled_at: DateTime.utc_now()
      })

    case Repo.insert(enrollment_changeset) do
      {:ok, enrollment} -> {:ok, enrollment}
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_enrollment_for_cancellation(enrollment_id) do
    case get_enrollment(enrollment_id) do
      nil -> {:error, :enrollment_not_found}
      %Enrollment{status: :cancelled} -> {:error, :already_cancelled}
      enrollment -> {:ok, enrollment}
    end
  end

  defp validate_exists(nil), do: {:error, :not_found}
  defp validate_exists(entity), do: {:ok, entity}

  defp cancel_enrollment_with_slot_increment(enrollment, _course) do
    cancel_changeset =
      Enrollment.changeset(enrollment, %{
        status: :cancelled,
        cancelled_at: DateTime.utc_now()
      })

    case Repo.update(cancel_changeset) do
      {:ok, enrollment} -> {:ok, enrollment}
      {:error, reason} -> {:error, reason}
    end
  end
end
