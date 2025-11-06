defmodule Fractal.Accounts.Services.AuthService do
  @moduledoc """
  Servicio de autenticación.
  """
  alias Fractal.Accounts.Services.UserService
  alias Fractal.Accounts.Guardian

  @doc """
  Registra un nuevo usuario (siempre como :student por defecto).
  """
  def register_user(attrs) do
    with {:ok, user} <- attrs |> Map.put(:role, :student) |> UserService.create_user(),
         {:ok, token, _claims} <- Guardian.generate_token(user) do
      {:ok, user, token}
    end
  end

  @doc """
  Autentica usuario con email y password.
  Retorna el usuario con su token JWT si las credenciales son correctas.
  """
  def authenticate(email, password) do
    case UserService.get_user_by_email(email) do
      nil ->
        Pbkdf2.no_user_verify()
        {:error, :invalid_credentials}

      user ->
        if Pbkdf2.verify_pass(password, user.password_hash) do
          case Guardian.generate_token(user) do
            {:ok, token, _claims} -> {:ok, user, token}
            error -> error
          end
        else
          {:error, :invalid_credentials}
        end
    end
  end

  @doc """
  Verifica si un token JWT es válido.
  Retorna el usuario si el token es válido.
  """
  def verify_token(token) do
    case Guardian.verify_token(token) do
      {:ok, claims} -> Guardian.resource_from_claims(claims)
      error -> error
    end
  end
end
