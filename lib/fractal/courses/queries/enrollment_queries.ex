defmodule Fractal.Courses.Queries.EnrollmentQueries do
  @moduledoc """
  Queries reutilizables para el schema Enrollment.
  """
  import Ecto.Query
  alias Fractal.Courses.Schemas.Enrollment

  def by_user(user_id) do
    from e in Enrollment, where: e.user_id == ^user_id
  end

  def by_course(course_id) do
    from e in Enrollment, where: e.course_id == ^course_id
  end

  def active do
    from e in Enrollment, where: e.status == :active
  end

  def active_by_user(user_id) do
    from e in Enrollment,
      where: e.user_id == ^user_id and e.status == :active
  end

  def active_by_course(course_id) do
    from e in Enrollment,
      where: e.course_id == ^course_id and e.status == :active
  end

  def exists?(user_id, course_id) do
    from e in Enrollment,
      where: e.user_id == ^user_id and e.course_id == ^course_id and e.status == :active
  end

  def preload_associations(query \\ Enrollment) do
    from e in query, preload: [:user, :course]
  end
end
