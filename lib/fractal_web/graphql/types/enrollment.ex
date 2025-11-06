defmodule FractalWeb.GraphQL.Types.Enrollment do
  @moduledoc """
  Tipo GraphQL para Inscripciones.
  """
  use Absinthe.Schema.Notation

  @desc "Inscripción de un usuario a un curso"
  object :enrollment do
    field :id, non_null(:id), description: "ID único de la inscripción"
    field :user, non_null(:user), description: "Usuario inscrito"
    field :course, non_null(:course), description: "Curso al que está inscrito"
    field :status, non_null(:enrollment_status), description: "Estado de la inscripción"
    field :enrolled_at, :datetime, description: "Fecha de inscripción"
    field :cancelled_at, :datetime, description: "Fecha de cancelación (si aplica)"
    field :inserted_at, non_null(:datetime), description: "Fecha de creación del registro"
    field :updated_at, non_null(:datetime), description: "Fecha de última actualización"
  end

  @desc "Estados posibles de una inscripción"
  enum :enrollment_status do
    value(:active, description: "Inscripción activa")
    value(:cancelled, description: "Inscripción cancelada")
    value(:completed, description: "Curso completado")
  end
end
