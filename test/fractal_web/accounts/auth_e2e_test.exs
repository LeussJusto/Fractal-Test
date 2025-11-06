defmodule FractalWeb.GraphQL.AuthE2ETest do
  use FractalWeb.ConnCase, async: true

  @register_mutation """
  mutation Register($email: String!, $password: String!, $firstName: String!, $lastName: String!) {
    register(email: $email, password: $password, first_name: $firstName, last_name: $lastName) {
      token
      user {
        id
        email
        first_name
        last_name
        role
      }
    }
  }
  """

  @login_mutation """
  mutation Login($email: String!, $password: String!) {
    login(email: $email, password: $password) {
      token
      user {
        id
        email
        first_name
        last_name
        role
      }
    }
  }
  """

  test "flujo completo de registro", %{conn: conn} do
    variables = %{
      "email" => "test@uni.com",
      "password" => "12345678",
      "firstName" => "Test",
      "lastName" => "User"
    }

    response =
      post(conn, "/api/graphql", %{
        "query" => @register_mutation,
        "variables" => variables
      })

    data = json_response(response, 200)["data"]["register"]
    assert is_binary(data["token"])
    assert data["user"]["email"] == "test@uni.com"
    assert data["user"]["role"] == "STUDENT"
  end

  test "flujo completo de login", %{conn: conn} do
    variables = %{
      "email" => "test2@uni.com",
      "password" => "12345678",
      "firstName" => "Test",
      "lastName" => "User"
    }

    post(conn, "/api/graphql", %{
      "query" => @register_mutation,
      "variables" => variables
    })

    login_vars = %{
      "email" => "test2@uni.com",
      "password" => "12345678"
    }

    response =
      post(conn, "/api/graphql", %{
        "query" => @login_mutation,
        "variables" => login_vars
      })

    data = json_response(response, 200)["data"]["login"]
    assert is_binary(data["token"])
    assert data["user"]["email"] == "test2@uni.com"
    assert data["user"]["role"] == "STUDENT"
  end
end
