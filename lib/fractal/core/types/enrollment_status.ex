defmodule Fractal.Core.Types.EnrollmentStatus do
  @moduledoc """
  Enum centralizado para los estados de matrícula (enrollment).
  """
  @type t :: :active | :cancelled | :completed
  @values [:active, :cancelled, :completed]

  @spec values() :: [t()]
  def values, do: @values
end
