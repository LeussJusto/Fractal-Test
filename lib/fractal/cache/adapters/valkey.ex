defmodule Fractal.Cache.Adapters.Valkey do
  @behaviour Fractal.Core.Behaviors.CacheAdapterBehaviour
  @moduledoc """
  Adapter para cache con Valkey/Redis.
  """
  @default_expiry 60

  def get(key) do
    case Redix.command(:redix, ["GET", key]) do
      {:ok, nil} -> nil
      {:ok, value} -> :erlang.binary_to_term(value)
      {:error, _} -> nil
    end
  end

  def set(key, value) do
    # set/2 para cumplir el behaviour principal
    Redix.command(:redix, ["SET", key, :erlang.term_to_binary(value), "EX", @default_expiry])
  end

  def set(key, value, opts) do
    # set/3 para compatibilidad con otros usos
    expiry = Keyword.get(opts, :expiry, @default_expiry)
    Redix.command(:redix, ["SET", key, :erlang.term_to_binary(value), "EX", expiry])
  end

  def delete(key), do: del(key)

  def del(key) do
    Redix.command(:redix, ["DEL", key])
  end
end
