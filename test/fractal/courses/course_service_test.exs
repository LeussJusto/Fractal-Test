defmodule Fractal.Courses.Services.CourseServiceTest do
  use Fractal.DataCase, async: true

  alias Fractal.Courses.Services.CourseService
  alias Fractal.Courses.Schemas.Course

  describe "create_course/1" do
    test "crea un curso y lo retorna" do
      attrs = %{
        name: "Matemáticas",
        code: "MAT101",
        description: "Curso básico de matemáticas",
        capacity: 30
      }

      assert {:ok, %Course{} = course} = CourseService.create_course(attrs)
      assert course.name == attrs.name
      assert course.code == attrs.code
      assert course.capacity == attrs.capacity
      assert course.available_slots == attrs.capacity
    end
  end

  describe "get_course/1" do
    test "obtiene un curso por id" do
      attrs = %{
        name: "Física",
        code: "FIS101",
        description: "Curso básico de física",
        capacity: 25
      }

      {:ok, course} = CourseService.create_course(attrs)
      found = CourseService.get_course(course.id)
      assert found.id == course.id
      assert found.name == course.name
    end
  end

  describe "update_course/2" do
    test "actualiza los datos de un curso" do
      attrs = %{
        name: "Química",
        code: "QUI101",
        description: "Curso básico de química",
        capacity: 20
      }

      {:ok, course} = CourseService.create_course(attrs)
      update_attrs = %{name: "Química Avanzada", capacity: 40}
      assert {:ok, updated} = CourseService.update_course(course, update_attrs)
      assert updated.name == "Química Avanzada"
      assert updated.capacity == 40
    end
  end

  describe "delete_course/1" do
    test "elimina un curso" do
      attrs = %{
        name: "Historia",
        code: "HIS101",
        description: "Curso básico de historia",
        capacity: 15
      }

      {:ok, course} = CourseService.create_course(attrs)
      assert {:ok, _} = CourseService.delete_course(course)
      assert CourseService.get_course(course.id) == nil
    end
  end
end
