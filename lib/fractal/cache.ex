defmodule Fractal.Cache do
  @moduledoc """
  API de cache.
  """
  @adapter Application.compile_env(:fractal, :cache_adapter, Fractal.Cache.Adapters.Valkey)

  def get(key), do: @adapter.get(key)
  def set(key, value, opts \\ []), do: @adapter.set(key, value, opts)
  def del(key), do: @adapter.del(key)
end
