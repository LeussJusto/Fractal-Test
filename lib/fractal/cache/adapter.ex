defmodule Fractal.Cache.Adapter do
  @moduledoc """
  Comportamiento para adapters de cache.
  """
  @callback get(String.t()) :: any
  @callback set(String.t(), any, keyword) :: any
  @callback del(String.t()) :: any
end
