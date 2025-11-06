defmodule Fractal.Core.Behaviors.UserServiceBehaviour do
  @moduledoc """
  Behaviour para el servicio de usuarios. Permite registrar y consultar usuarios.
  """
  @callback create_user(map()) :: {:ok, any()} | {:error, any()}
  @callback get_user_by_email(String.t()) :: any() | nil
end
