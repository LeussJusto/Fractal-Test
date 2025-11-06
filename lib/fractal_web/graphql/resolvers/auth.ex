defmodule FractalWeb.GraphQL.Resolvers.Auth do
  @moduledoc """
  Resolvers para operaciones de autenticación.
  Maneja registro, login y obtención del usuario actual.
  """

  alias Fractal.Accounts.Services.AuthService

  @doc """
  Registra un nuevo usuario y retorna el token JWT.
  """
  def register(_parent, args, _resolution) do
    case AuthService.register_user(args) do
      {:ok, user, token} ->
        {:ok, %{user: user, token: token}}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, format_changeset_errors(changeset)}

      {:error, reason} ->
        {:error, message: "Error al registrar usuario: #{inspect(reason)}"}
    end
  end

  @doc """
  Autentica un usuario y retorna el token JWT.
  """
  def login(_parent, %{email: email, password: password}, _resolution) do
    case AuthService.authenticate(email, password) do
      {:ok, user, token} ->
        {:ok, %{user: user, token: token}}

      {:error, :invalid_credentials} ->
        {:error, message: "Email o contraseña incorrectos"}

      {:error, reason} ->
        {:error, message: "Error al autenticar: #{inspect(reason)}"}
    end
  end

  @doc """
  Obtiene el usuario actual desde el contexto.
  La autenticación es manejada por el middleware Authenticate.
  """
  def me(_parent, _args, %{context: %{current_user: user}}) do
    {:ok, user}
  end

  # Helper privado para formatear errores de changeset
  defp format_changeset_errors(changeset) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
          opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
        end)
      end)

    %{
      message: "Error de validación",
      details: errors
    }
  end
end
