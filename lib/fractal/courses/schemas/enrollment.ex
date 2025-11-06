defmodule Fractal.Courses.Schemas.Enrollment do
  @moduledoc """
  Schema para matrículas (inscripciones de alumnos a cursos).
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Fractal.Accounts.Schemas.User
  alias Fractal.Courses.Schemas.Course
  alias Fractal.Core.Types.EnrollmentStatus

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "enrollments" do
    field :status, Ecto.Enum, values: EnrollmentStatus.values(), default: :active
    field :enrolled_at, :utc_datetime
    field :cancelled_at, :utc_datetime

    belongs_to :user, User
    belongs_to :course, Course

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset para crear/actualizar matrícula.
  """
  def changeset(enrollment, attrs) do
    enrollment
    |> cast(attrs, [:user_id, :course_id, :status, :enrolled_at, :cancelled_at])
    |> validate_required([:user_id, :course_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:course_id)
    |> unique_constraint([:user_id, :course_id], name: :enrollments_user_id_course_id_index)
  end
end
