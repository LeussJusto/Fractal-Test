defmodule Fractal.Accounts.Queries.UserQueries do
  @moduledoc """
  Queries para usuarios.
  """
  import Ecto.Query, warn: false
  alias Fractal.Accounts.Schemas.User

  def by_email(email) do
    from u in User, where: u.email == ^email
  end

  def by_role(role) do
    from u in User, where: u.role == ^role, order_by: [asc: u.first_name]
  end

  def all_ordered do
    from u in User, order_by: [asc: u.first_name, asc: u.last_name]
  end
end
