defmodule FractalWeb.GraphQL.NotificationE2ETest do
  use FractalWeb.ConnCase, async: false
  import Phoenix.ChannelTest

  @endpoint FractalWeb.Endpoint

  setup do
    :ok =
      case :brod.start_link_client([{~c"redpanda", 9092}], :kafka_client, []) do
        {:ok, _pid} -> :ok
        {:error, {:already_started, _pid}} -> :ok
        {:error, reason} -> raise "No se pudo iniciar Kafka client: #{inspect(reason)}"
      end

    :ok = :brod.start_producer(:kafka_client, "notifications", [])

    start_supervised!(Fractal.Notifications.Broadcasters.NotificationBroadway)

    :ok
  end

  @register_mutation """
  mutation Register($email: String!, $password: String!, $firstName: String!, $lastName: String!) {
    register(email: $email, password: $password, first_name: $firstName, last_name: $lastName) {
      token
      user { id email }
    }
  }
  """

  @create_course_mutation """
  mutation CreateCourse($name: String!, $code: String!, $description: String!, $capacity: Int!) {
    createCourse(name: $name, code: $code, description: $description, capacity: $capacity) {
      id
      name
      code
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

  test "notifica inscripción por GraphQL y canal", %{conn: conn} do
    reg_vars = %{
      "email" => "student@test.com",
      "password" => "12345678",
      "firstName" => "Student",
      "lastName" => "Test"
    }

    reg_resp =
      post(conn, "/api/graphql", %{"query" => @register_mutation, "variables" => reg_vars})

    user = json_response(reg_resp, 200)["data"]["register"]["user"]
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

    {:ok, _, _socket} =
      subscribe_and_join(
        socket(@endpoint),
        FractalWeb.NotificationChannel,
        "notifications:" <> user["id"]
      )

    enroll_resp =
      post(conn_auth, "/api/graphql", %{
        "query" => @enroll_mutation,
        "variables" => %{"courseId" => course_id}
      })

    assert json_response(enroll_resp, 200)["data"]["enrollInCourse"]["status"] == "ACTIVE"

    assert_broadcast "new_notification", payload, 5000
    assert payload["type"] == "enrollment_created"
    assert payload["user_id"] == user["id"]
    assert payload["course_id"] == course_id
    assert is_binary(payload["timestamp"])
  end
end
