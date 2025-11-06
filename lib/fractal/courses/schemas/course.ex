defmodule Fractal.Courses.Schemas.Course do
  @moduledoc """
  Schema para cursos.
  Representa un curso con capacidad limitada de alumnos.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Fractal.Courses.Schemas.Enrollment

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "courses" do
    field :name, :string
    field :code, :string
    field :description, :string
    field :capacity, :integer
    field :available_slots, :integer

    has_many :enrollments, Enrollment

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset para crear/actualizar curso.
  """
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :code, :description, :capacity, :available_slots])
    |> validate_required([:name, :code, :capacity])
    |> validate_number(:capacity, greater_than: 0)
    |> validate_number(:available_slots, greater_than_or_equal_to: 0)
    |> unique_constraint(:code)
    |> put_available_slots()
  end

  defp put_available_slots(changeset) do
    case get_field(changeset, :available_slots) do
      nil ->
        capacity = get_field(changeset, :capacity)
        put_change(changeset, :available_slots, capacity)

      _slots ->
        changeset
    end
  end
end
