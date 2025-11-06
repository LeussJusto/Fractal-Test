defmodule Fractal.Courses.Services.CourseService do
  @behaviour Fractal.Core.Behaviors.CourseServiceBehaviour
  @moduledoc """
  Servicio para operaciones CRUD de cursos.
  Maneja caché, validaciones y sincronización de cupos.
  """

  import Ecto.Query
  alias Fractal.Repo
  alias Fractal.Courses.Schemas.Course
  alias Fractal.Courses.Queries.CourseQueries

  @doc """
  Lista todos los cursos ordenados por nombre, con caché de 60 segundos.
  """
  def list_courses do
    cache_key = "all_courses"

    case Fractal.Cache.get(cache_key) do
      nil ->
        courses = CourseQueries.all_ordered() |> Repo.all()
        Fractal.Cache.set(cache_key, courses, expiry: 60)
        courses

      cached ->
        cached
    end
  end

  @doc """
  Lista los cursos que aún tienen cupos disponibles.
  """
  def list_available_courses do
    cache_key = "available_courses"

    case Fractal.Cache.get(cache_key) do
      nil ->
        courses =
          CourseQueries.with_available_slots()
          |> order_by([c], asc: c.name)
          |> Repo.all()

        Fractal.Cache.set(cache_key, courses, expiry: 60)
        courses

      cached ->
        cached
    end
  end

  @doc """
  Lista los cursos que ya están llenos (sin cupos).
  """
  def list_full_courses do
    CourseQueries.full_courses()
    |> order_by([c], asc: c.name)
    |> Repo.all()
  end

  @doc """
  Obtiene un curso por su ID, usando caché.
  """
  def get_course(id) do
    cache_key = "course_" <> to_string(id)

    case Fractal.Cache.get(cache_key) do
      nil ->
        course = Repo.get(Course, id)
        if course, do: Fractal.Cache.set(cache_key, course, expiry: 60)
        course

      cached ->
        cached
    end
  end

  @doc """
  Obtiene un curso con sus inscripciones precargadas.
  """
  def get_course_with_enrollments(id) do
    Course
    |> CourseQueries.preload_enrollments()
    |> Repo.get(id)
  end

  @doc """
  Obtiene un curso por su código.
  """
  def get_course_by_code(code) do
    cache_key = "course_by_code_" <> to_string(code)

    case Fractal.Cache.get(cache_key) do
      nil ->
        course = CourseQueries.by_code(code) |> Repo.one()
        if course, do: Fractal.Cache.set(cache_key, course, expiry: 60)
        course

      cached ->
        cached
    end
  end

  @doc """
  Crea un nuevo curso.
  """
  def create_course(attrs) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Actualiza un curso existente e invalida la caché relacionada.
  """
  def update_course(%Course{} = course, attrs) do
    result =
      course
      |> Course.changeset(attrs)
      |> Repo.update()

    Fractal.Cache.del("course_" <> to_string(course.id))
    Fractal.Cache.del("all_courses")
    Fractal.Cache.del("available_courses")

    result
  end

  @doc """
  Elimina un curso e invalida la caché relacionada.
  """
  def delete_course(%Course{} = course) do
    result = Repo.delete(course)

    Fractal.Cache.del("course_" <> to_string(course.id))
    Fractal.Cache.del("all_courses")
    Fractal.Cache.del("available_courses")

    result
  end

  @doc """
  Decrementa el número de cupos disponibles (cuando un alumno se matricula).
  """
  def decrement_slots(%Course{} = course) do
    course
    |> Ecto.Changeset.change(available_slots: course.available_slots - 1)
    |> Repo.update()
  end

  @doc """
  Incrementa el número de cupos disponibles (cuando una matrícula se cancela).
  """
  def increment_slots(%Course{} = course) do
    course
    |> Ecto.Changeset.change(available_slots: course.available_slots + 1)
    |> Repo.update()
  end

  @doc """
  Actualiza el número de cupos disponibles con el valor sincronizado desde Redis.
  """
  def update_slots(%Course{} = course, slots) do
    course
    |> Ecto.Changeset.change(available_slots: slots)
    |> Repo.update()
  end
end
