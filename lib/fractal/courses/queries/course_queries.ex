defmodule Fractal.Courses.Queries.CourseQueries do
  @moduledoc """
  Queries reutilizables para el schema Course.
  """
  import Ecto.Query
  alias Fractal.Courses.Schemas.Course

  def all_ordered do
    from c in Course, order_by: [asc: c.name]
  end

  def by_code(code) do
    from c in Course, where: c.code == ^code
  end

  def with_available_slots do
    from c in Course, where: c.available_slots > 0
  end

  def full_courses do
    from c in Course, where: c.available_slots == 0
  end

  def preload_enrollments(query \\ Course) do
    from c in query, preload: [:enrollments]
  end
end
