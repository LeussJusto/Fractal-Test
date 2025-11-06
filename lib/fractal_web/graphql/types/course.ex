defmodule FractalWeb.GraphQL.Types.Course do
  @moduledoc """
  Tipo GraphQL para Curso.
  """
  use Absinthe.Schema.Notation

  @desc "Curso académico"
  object :course do
    field :id, non_null(:id), description: "ID único del curso"
    field :name, non_null(:string), description: "Nombre del curso"
    field :code, non_null(:string), description: "Código único del curso (ej: MATH101)"
    field :description, :string, description: "Descripción del curso"
    field :capacity, non_null(:integer), description: "Capacidad total del curso"

    field :available_slots, non_null(:integer), description: "Cupos disponibles actualmente"

    field :inserted_at, non_null(:string), description: "Fecha de creación"
    field :updated_at, non_null(:string), description: "Fecha de última actualización"
  end
end
