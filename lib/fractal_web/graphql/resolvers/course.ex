defmodule FractalWeb.GraphQL.Resolvers.Course do
  @moduledoc """
  Resolvers para operaciones de cursos.
  Maneja queries y mutations relacionadas con cursos.
  """

  alias Fractal.Courses.Services.CourseService

  @doc """
  Lista todos los cursos.
  """
  def list_courses(_parent, _args, _resolution) do
    {:ok, CourseService.list_courses()}
  end

  @doc """
  Lista solo cursos con cupos disponibles.
  """
  def list_available_courses(_parent, _args, _resolution) do
    {:ok, CourseService.list_available_courses()}
  end

  @doc """
  Obtiene un curso por ID.
  """
  def get_course(_parent, %{id: id}, _resolution) do
    case CourseService.get_course(id) do
      nil -> {:error, message: "Curso no encontrado"}
      course -> {:ok, course}
    end
  end

  @doc """
  Obtiene un curso por código.
  """
  def get_course_by_code(_parent, %{code: code}, _resolution) do
    case CourseService.get_course_by_code(code) do
      nil -> {:error, message: "Curso no encontrado"}
      course -> {:ok, course}
    end
  end

  @doc """
  Crea un nuevo curso.
  Requiere autenticación (manejada por middleware).
  """
  def create_course(_parent, args, _resolution) do
    case CourseService.create_course(args) do
      {:ok, course} ->
        {:ok, course}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, format_changeset_errors(changeset)}

      {:error, reason} ->
        {:error, message: "Error al crear curso: #{inspect(reason)}"}
    end
  end

  @doc """
  Actualiza un curso existente.
  Requiere autenticación (manejada por middleware).
  """
  def update_course(_parent, %{id: id} = args, _resolution) do
    with {:ok, course} <- get_course_for_update(id),
         {:ok, updated_course} <- CourseService.update_course(course, args) do
      {:ok, updated_course}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, format_changeset_errors(changeset)}

      {:error, reason} ->
        {:error, message: "Error al actualizar curso: #{inspect(reason)}"}
    end
  end

  @doc """
  Elimina un curso.
  Requiere autenticación (manejada por middleware).
  """
  def delete_course(_parent, %{id: id}, _resolution) do
    case CourseService.get_course(id) do
      nil ->
        {:error, message: "Curso no encontrado"}

      course ->
        case CourseService.delete_course(course) do
          {:ok, deleted_course} ->
            {:ok, deleted_course}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:error, format_changeset_errors(changeset)}

          {:error, reason} ->
            {:error, message: "Error al eliminar curso: #{inspect(reason)}"}
        end
    end
  end

  # Helpers privados

  defp get_course_for_update(id) do
    case CourseService.get_course(id) do
      nil -> {:error, message: "Curso no encontrado"}
      course -> {:ok, course}
    end
  end

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
