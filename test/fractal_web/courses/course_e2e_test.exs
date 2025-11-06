defmodule FractalWeb.GraphQL.CourseE2ETest do
  use FractalWeb.ConnCase, async: true

  @create_course_mutation """
  mutation CreateCourse($name: String!, $code: String!, $description: String!, $capacity: Int!) {
    createCourse(name: $name, code: $code, description: $description, capacity: $capacity) {
      id
      name
      code
      description
      capacity
      availableSlots
    }
  }
  """

  @update_course_mutation """
  mutation UpdateCourse($id: ID!, $name: String!, $description: String!) {
    updateCourse(id: $id, name: $name, description: $description) {
      id
      name
      code
      description
      capacity
      availableSlots
    }
  }
  """

  @delete_course_mutation """
  mutation DeleteCourse($id: ID!) {
    deleteCourse(id: $id) {
      id
      name
      code
    }
  }
  """

  @get_course_query """
  query GetCourse($id: ID!) {
    course(id: $id) {
      id
      name
      code
      description
      capacity
      availableSlots
    }
  }
  """

  test "flujo completo de crear, actualizar y eliminar curso", %{conn: conn} do
    register_query = """
    mutation Register($email: String!, $password: String!, $firstName: String!, $lastName: String!) {
      register(email: $email, password: $password, firstName: $firstName, lastName: $lastName) {
        token
        user { id email firstName lastName role }
      }
    }
    """

    reg_vars = %{
      "email" => "admin@test.com",
      "password" => "Admin123!",
      "firstName" => "Admin",
      "lastName" => "User"
    }

    reg_resp = post(conn, "/api/graphql", %{"query" => register_query, "variables" => reg_vars})
    token = json_response(reg_resp, 200)["data"]["register"]["token"]

    variables = %{
      "name" => "Matemáticas",
      "code" => "MAT101",
      "description" => "Curso básico de matemáticas",
      "capacity" => 30
    }

    conn_auth = put_req_header(conn, "authorization", "Bearer #{token}")

    response =
      post(conn_auth, "/api/graphql", %{
        "query" => @create_course_mutation,
        "variables" => variables
      })

    data = json_response(response, 200)["data"]["createCourse"]
    assert data["name"] == "Matemáticas"
    assert data["code"] == "MAT101"
    assert data["capacity"] == 30
    assert data["availableSlots"] == 30

    get_vars = %{"id" => data["id"]}

    get_response =
      post(conn, "/api/graphql", %{
        "query" => @get_course_query,
        "variables" => get_vars
      })

    get_data = json_response(get_response, 200)["data"]["course"]
    assert get_data["id"] == data["id"]
    assert get_data["name"] == "Matemáticas"
    assert get_data["code"] == "MAT101"

    update_vars = %{
      "id" => data["id"],
      "name" => "Matemáticas Avanzadas",
      "description" => "Curso avanzado de matemáticas"
    }

    update_response =
      post(conn_auth, "/api/graphql", %{
        "query" => @update_course_mutation,
        "variables" => update_vars
      })

    update_data = json_response(update_response, 200)["data"]["updateCourse"]
    assert update_data["id"] == data["id"]
    assert update_data["name"] == "Matemáticas Avanzadas"
    assert update_data["description"] == "Curso avanzado de matemáticas"

    delete_vars = %{"id" => data["id"]}

    delete_response =
      post(conn_auth, "/api/graphql", %{
        "query" => @delete_course_mutation,
        "variables" => delete_vars
      })

    delete_data = json_response(delete_response, 200)["data"]["deleteCourse"]
    assert delete_data["id"] == data["id"]
    assert delete_data["name"] == "Matemáticas Avanzadas"
    assert delete_data["code"] == "MAT101"
  end
end
