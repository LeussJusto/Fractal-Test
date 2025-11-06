defmodule Fractal.Core.Types.UserRole do
  @moduledoc """
  Ecto type para roles de usuario (:student, :admin, :teacher, etc).
  """
  use Ecto.Type

  @roles [:student, :admin, :teacher]

  def type, do: :string

  def cast(role) when is_atom(role) and role in @roles, do: {:ok, role}

  def cast(role) when is_binary(role) do
    atom = String.to_atom(role)
    if atom in @roles, do: {:ok, atom}, else: :error
  end

  def cast(_), do: :error

  def load(role) when is_binary(role), do: cast(role)
  def load(_), do: :error

  def dump(role) when is_atom(role) and role in @roles, do: {:ok, Atom.to_string(role)}
  def dump(_), do: :error

  def roles, do: @roles
end
