defmodule Fractal.Courses.Services.EnrollmentServiceTest do
  use Fractal.DataCase, async: false

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Fractal.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Fractal.Repo, {:shared, self()})

    pid = Process.whereis(Fractal.Courses.GenServers.CourseSlotManager)
    Ecto.Adapters.SQL.Sandbox.allow(Fractal.Repo, self(), pid)

    :ok
  end

  alias Fractal.Courses.Services.{EnrollmentService, CourseService}
  alias Fractal.Accounts.Services.UserService
  alias Fractal.Courses.Schemas.Enrollment

  describe "enroll_user/2" do
    test "inscribe un usuario en un curso y lo retorna" do
      {:ok, user} =
        UserService.create_user(%{
          email: "student@test.com",
          password: "12345678",
          first_name: "Student",
          last_name: "Test"
        })

      {:ok, course} =
        CourseService.create_course(%{
          name: "Biología",
          code: "BIO101",
          description: "Curso básico de biología",
          capacity: 10
        })

      assert {:ok, %Enrollment{} = enrollment} = EnrollmentService.enroll_user(user.id, course.id)
      assert enrollment.user_id == user.id
      assert enrollment.course_id == course.id
      assert enrollment.status == :active
    end
  end

  describe "cancel_enrollment_by_id/1" do
    test "cancela la inscripción y actualiza el estado" do
      {:ok, user} =
        UserService.create_user(%{
          email: "student2@test.com",
          password: "12345678",
          first_name: "Student",
          last_name: "Test"
        })

      {:ok, course} =
        CourseService.create_course(%{
          name: "Química",
          code: "QUI101",
          description: "Curso básico de química",
          capacity: 5
        })

      {:ok, enrollment} = EnrollmentService.enroll_user(user.id, course.id)
      assert enrollment.status == :active

      assert {:ok, cancelled} = EnrollmentService.cancel_enrollment_by_id(enrollment.id)
      assert cancelled.status == :cancelled
      assert cancelled.cancelled_at != nil
    end
  end

  describe "list_user_enrollments/1" do
    test "lista las inscripciones de un usuario" do
      {:ok, user} =
        UserService.create_user(%{
          email: "student3@test.com",
          password: "12345678",
          first_name: "Student",
          last_name: "Test"
        })

      {:ok, course} =
        CourseService.create_course(%{
          name: "Historia",
          code: "HIS101",
          description: "Curso básico de historia",
          capacity: 8
        })

      {:ok, enrollment} = EnrollmentService.enroll_user(user.id, course.id)

      enrollments = EnrollmentService.list_user_enrollments(user.id)
      assert Enum.any?(enrollments, &(&1.id == enrollment.id))
    end
  end

  describe "list_course_enrollments/1" do
    test "lista las inscripciones de un curso" do
      {:ok, user} =
        UserService.create_user(%{
          email: "student4@test.com",
          password: "12345678",
          first_name: "Student",
          last_name: "Test"
        })

      {:ok, course} =
        CourseService.create_course(%{
          name: "Filosofía",
          code: "FIL101",
          description: "Curso básico de filosofía",
          capacity: 12
        })

      {:ok, enrollment} = EnrollmentService.enroll_user(user.id, course.id)

      enrollments = EnrollmentService.list_course_enrollments(course.id)
      assert Enum.any?(enrollments, &(&1.id == enrollment.id))
    end
  end
end
