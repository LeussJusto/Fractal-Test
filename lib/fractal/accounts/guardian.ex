defmodule Fractal.Accounts.Guardian do
  @moduledoc """
  Implementación de Guardian para autenticación JWT.
  """
  use Guardian, otp_app: :fractal

  alias Fractal.Accounts.Services.UserService

  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, :invalid_resource}
  end

  @doc """
  Decodifica el token y obtiene el usuario desde la DB.
  Llamado automáticamente por Guardian cuando verifica un token.
  """
  def resource_from_claims(%{"sub" => user_id}) do
    case UserService.get_user(user_id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end

  @doc """
  Genera un token JWT con claims personalizados.
  Incluye el role del usuario en los claims.
  """
  def generate_token(user) do
    claims = %{
      "role" => user.role,
      "email" => user.email
    }

    encode_and_sign(user, claims, ttl: {7, :days})
  end

  @doc """
  Verifica si un token es válido.
  """
  def verify_token(token) do
    decode_and_verify(token)
  end
end
