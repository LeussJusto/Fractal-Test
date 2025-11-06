defmodule Fractal.Accounts.Schemas.User do
  @moduledoc """
  Schema para usuarios del sistema.
  Representa tanto alumnos como administradores.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true, redact: true
    field :first_name, :string
    field :last_name, :string
    field :role, Fractal.Core.Types.UserRole, default: :student

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset para crear/actualizar usuario.
  Si incluye password, lo hashea automáticamente.
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :first_name, :last_name, :role])
    |> validate_required([:email, :first_name, :last_name])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> maybe_validate_password()
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp maybe_validate_password(changeset) do
    if is_nil(get_field(changeset, :password_hash)) do
      changeset
      |> validate_required([:password])
      |> validate_length(:password, min: 8)
    else
      validate_length(changeset, :password, min: 8)
    end
  end

  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil ->
        changeset

      password ->
        changeset
        |> put_change(:password_hash, Pbkdf2.hash_pwd_salt(password))
        |> delete_change(:password)
    end
  end
end
