defmodule Fractal.Courses.GenServers.CourseSlotManager do
  @moduledoc """
  GenServer para manejar la disponibilidad de cupos en cursos con Redis.
  """
  use GenServer
  require Logger

  alias Fractal.Courses.Services.CourseService
  alias Fractal.Courses.Schemas.Course

  # Redis keys
  @redis_slots_key_prefix "course:slots:"
  @redis_lock_key_prefix "course:lock:"
  @lock_ttl_ms 5_000
  @lock_retry_delay_ms 50

  # Client API

  @doc """
  Inicia el GenServer.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def reserve_slot(course_id, timeout \\ 5000) do
    GenServer.call(__MODULE__, {:reserve_slot, course_id}, timeout)
  end

  def release_slot(course_id) do
    GenServer.call(__MODULE__, {:release_slot, course_id})
  end

  def get_available_slots(course_id) do
    GenServer.call(__MODULE__, {:get_slots, course_id})
  end

  def sync_from_db(course_id) do
    GenServer.cast(__MODULE__, {:sync_from_db, course_id})
  end

  def reload_all_courses do
    GenServer.cast(__MODULE__, :reload_all)
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    Logger.info("CourseSlotManager iniciado con Redis")
    {:ok, %{redis_conn: :redix}}
  end

  # handle_info(:load_courses) eliminado: la carga inicial ahora es manual

  @impl true
  def handle_call({:reserve_slot, course_id}, _from, state) do
    result =
      with_redis_lock(course_id, fn ->
        redis_key = slots_key(course_id)

        case Redix.command(:redix, ["GET", redis_key]) do
          {:ok, nil} ->
            # No existe en Redis, cargar desde DB
            case load_course_to_redis(course_id) do
              {:ok, slots} when slots > 0 ->
                decrement_redis_slots(course_id)

              {:ok, 0} ->
                {:error, :no_slots}

              error ->
                error
            end

          {:ok, slots_str} ->
            slots = String.to_integer(slots_str)

            if slots > 0 do
              decrement_redis_slots(course_id)
            else
              {:error, :no_slots}
            end

          {:error, reason} ->
            Logger.error("Error leyendo slots desde Redis: #{inspect(reason)}")
            {:error, :redis_error}
        end
      end)

    {:reply, result, state}
  end

  @impl true
  def handle_call({:release_slot, course_id}, _from, state) do
    result =
      with_redis_lock(course_id, fn ->
        redis_key = slots_key(course_id)

        case Redix.command(:redix, ["INCR", redis_key]) do
          {:ok, new_slots} ->
            Logger.debug("Slot liberado para curso #{course_id}. Slots disponibles: #{new_slots}")
            {:ok, :slot_released}

          {:error, reason} ->
            Logger.error("Error incrementando slots en Redis: #{inspect(reason)}")
            {:error, :redis_error}
        end
      end)

    {:reply, result, state}
  end

  @impl true
  def handle_call({:get_slots, course_id}, _from, state) do
    redis_key = slots_key(course_id)

    result =
      case Redix.command(:redix, ["GET", redis_key]) do
        {:ok, nil} ->
          # No existe en Redis, cargar desde DB
          case load_course_to_redis(course_id) do
            {:ok, slots} -> {:ok, slots}
            error -> error
          end

        {:ok, slots_str} ->
          {:ok, String.to_integer(slots_str)}

        {:error, reason} ->
          Logger.error("Error leyendo slots desde Redis: #{inspect(reason)}")
          {:error, :redis_error}
      end

    {:reply, result, state}
  end

  @impl true
  def handle_cast({:sync_from_db, course_id}, state) do
    case load_course_to_redis(course_id) do
      {:ok, slots} ->
        Logger.info("Curso #{course_id} sincronizado desde DB a Redis. Slots: #{slots}")

      {:error, reason} ->
        Logger.warning("No se pudo sincronizar curso #{course_id}: #{inspect(reason)}")
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast(:reload_all, state) do
    Logger.info("Recargando todos los cursos desde la base de datos a Redis")
    load_courses_to_redis()
    {:noreply, state}
  end

  # Private functions

  defp slots_key(course_id), do: @redis_slots_key_prefix <> course_id
  defp lock_key(course_id), do: @redis_lock_key_prefix <> course_id

  # Ejecuta una función dentro de un lock distribuido de Redis.
  # Implementa el patrón Redlock simplificado.
  defp with_redis_lock(course_id, func, retries \\ 10) do
    lock_key = lock_key(course_id)
    lock_value = :crypto.strong_rand_bytes(16) |> Base.encode64()

    case acquire_lock(lock_key, lock_value) do
      :ok ->
        try do
          func.()
        after
          release_lock(lock_key, lock_value)
        end

      :error when retries > 0 ->
        Process.sleep(@lock_retry_delay_ms)
        with_redis_lock(course_id, func, retries - 1)

      :error ->
        {:error, :lock_timeout}
    end
  end

  defp acquire_lock(lock_key, lock_value) do
    case Redix.command(:redix, ["SET", lock_key, lock_value, "PX", @lock_ttl_ms, "NX"]) do
      {:ok, "OK"} -> :ok
      {:ok, nil} -> :error
      {:error, _reason} -> :error
    end
  end

  defp release_lock(lock_key, lock_value) do
    script = """
    if redis.call("get", KEYS[1]) == ARGV[1] then
      return redis.call("del", KEYS[1])
    else
      return 0
    end
    """

    Redix.command(:redix, ["EVAL", script, "1", lock_key, lock_value])
  end

  defp decrement_redis_slots(course_id) do
    redis_key = slots_key(course_id)

    case Redix.command(:redix, ["DECR", redis_key]) do
      {:ok, new_slots} when new_slots >= 0 ->
        Logger.debug("Slot reservado para curso #{course_id}. Slots restantes: #{new_slots}")
        course = CourseService.get_course(course_id)
        CourseService.update_slots(course, new_slots)
        {:ok, :slot_reserved}

      {:ok, negative_slots} ->
        # Rollback: volver a incrementar
        Redix.command(:redix, ["INCR", redis_key])
        Logger.warning("Intento de reserva con slots negativos: #{negative_slots}")
        {:error, :no_slots}

      {:error, reason} ->
        Logger.error("Error decrementando slots en Redis: #{inspect(reason)}")
        {:error, :redis_error}
    end
  end

  defp load_courses_to_redis do
    CourseService.list_courses()
    |> Enum.each(fn %Course{id: id, available_slots: slots} ->
      redis_key = slots_key(id)
      Redix.command(:redix, ["SET", redis_key, slots])
    end)

    Logger.info("Cursos cargados a Redis desde la base de datos")
  rescue
    error ->
      Logger.error("Error cargando cursos a Redis: #{inspect(error)}")
  end

  defp load_course_to_redis(course_id) do
    case CourseService.get_course(course_id) do
      nil ->
        {:error, :course_not_found}

      %Course{available_slots: slots} ->
        redis_key = slots_key(course_id)

        case Redix.command(:redix, ["SET", redis_key, slots]) do
          {:ok, "OK"} -> {:ok, slots}
          {:error, reason} -> {:error, reason}
        end
    end
  rescue
    error ->
      Logger.error("Error cargando curso #{course_id} a Redis: #{inspect(error)}")
      {:error, :db_error}
  end
end
