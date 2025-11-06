defmodule Fractal.Accounts.Services.UserService do
  @behaviour Fractal.Core.Behaviors.UserServiceBehaviour
  @moduledoc """
  Servicio de usuarios - CRUD básico.
  """
  alias Fractal.Repo
  alias Fractal.Accounts.Schemas.User
  alias Fractal.Accounts.Queries.UserQueries

  def list_users do
    Repo.all(UserQueries.all_ordered())
  end

  def list_students do
    Repo.all(UserQueries.by_role(:student))
  end

  def list_admins do
    Repo.all(UserQueries.by_role(:admin))
  end

  def get_user(id) do
    cache_key = "user_" <> to_string(id)

    case Fractal.Cache.get(cache_key) do
      nil ->
        user = Repo.get(User, id)
        if user, do: Fractal.Cache.set(cache_key, user, expiry: 60)
        user

      cached ->
        cached
    end
  end

  def get_user_by_email(email) do
    Repo.one(UserQueries.by_email(email))
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    result = user |> User.changeset(attrs) |> Repo.update()

    case result do
      {:ok, updated} ->
        Fractal.Cache.del("user_" <> to_string(updated.id))
        {:ok, updated}

      error ->
        error
    end
  end

  def delete_user(%User{} = user), do: Repo.delete(user)
end
