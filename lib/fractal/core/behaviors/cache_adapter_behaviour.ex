defmodule Fractal.Core.Behaviors.CacheAdapterBehaviour do
  @moduledoc """
  Behaviour para adaptadores de caché (Redis, memoria, etc).
  """
  @callback get(String.t()) :: any() | nil
  @callback set(String.t(), any()) :: :ok | {:error, any()}
  @callback delete(String.t()) :: :ok | {:error, any()}
end
