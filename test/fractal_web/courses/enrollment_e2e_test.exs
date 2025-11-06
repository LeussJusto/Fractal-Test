defmodule FractalWeb.GraphQL.EnrollmentE2ETest do
  use FractalWeb.ConnCase, async: false

  @register_mutation """
  mutation Register($email: String!, $password: String!, $firstName: String!, $lastName: String!) {
    register(email: $email, password: $password, first_name: $firstName, last_name: $lastName) {
      token
      user { id email first_name last_name role }
    }
  }
  """

  @create_course_mutation """
  mutation CreateCourse($name: String!, $code: String!, $description: String!, $capacity: Int!) {
    createCourse(name: $name, code: $code, description: $description, capacity: $capacity) {
      id
      name
      code
      capacity
      availableSlots
    }
  }
  """

  @enroll_mutation """
  mutation Enroll($courseId: ID!) {
    enrollInCourse(courseId: $courseId) {
      id
      status
      user { id email }
      course { id name }
    }
  }
  """

  @cancel_enrollment_mutation """
  mutation CancelEnrollment($enrollmentId: ID!) {
    cancelEnrollment(enrollmentId: $enrollmentId) {
      id
      status
      cancelledAt
    }
  }
  """

  test "flujo completo de inscripción y cancelación", %{conn: conn} do
    reg_vars = %{
      "email" => "student@test.com",
      "password" => "12345678",
      "firstName" => "Student",
      "lastName" => "Test"
    }

    reg_resp =
      post(conn, "/api/graphql", %{"query" => @register_mutation, "variables" => reg_vars})

    token = json_response(reg_resp, 200)["data"]["register"]["token"]
    conn_auth = put_req_header(conn, "authorization", "Bearer #{token}")

    course_vars = %{
      "name" => "Biología",
      "code" => "BIO101",
      "description" => "Curso básico de biología",
      "capacity" => 10
    }

    course_resp =
      post(conn_auth, "/api/graphql", %{
        "query" => @create_course_mutation,
        "variables" => course_vars
      })

    course_id = json_response(course_resp, 200)["data"]["createCourse"]["id"]

    enroll_resp =
      post(conn_auth, "/api/graphql", %{
        "query" => @enroll_mutation,
        "variables" => %{"courseId" => course_id}
      })

    enrollment = json_response(enroll_resp, 200)["data"]["enrollInCourse"]
    IO.inspect(enrollment, label: "Enrollment mutation response")
    assert enrollment["status"] == "ACTIVE"

    cancel_resp =
      post(conn_auth, "/api/graphql", %{
        "query" => @cancel_enrollment_mutation,
        "variables" => %{"enrollmentId" => enrollment["id"]}
      })

    cancelled = json_response(cancel_resp, 200)["data"]["cancelEnrollment"]
    assert cancelled["status"] == "CANCELLED"
    assert cancelled["cancelledAt"] != nil
  end
end
