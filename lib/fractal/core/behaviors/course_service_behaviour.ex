defmodule Fractal.Core.Behaviors.CourseServiceBehaviour do
  @moduledoc """
  Behaviour para  servicio de cursos.
  """
  @callback create_course(map()) :: {:ok, any()} | {:error, any()}
  @callback get_course(binary()) :: any() | nil
  @callback get_course_by_code(String.t()) :: any() | nil
  @callback list_courses() :: [any()]
  @callback list_available_courses() :: [any()]
  @callback list_full_courses() :: [any()]
  @callback update_course(any(), map()) :: {:ok, any()} | {:error, any()}
  @callback delete_course(any()) :: {:ok, any()} | {:error, any()}
  @callback decrement_slots(any()) :: {:ok, any()} | {:error, any()}
  @callback increment_slots(any()) :: {:ok, any()} | {:error, any()}
end
