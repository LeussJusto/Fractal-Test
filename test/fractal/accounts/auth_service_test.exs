defmodule Fractal.Accounts.Services.AuthServiceTest do
  use Fractal.DataCase, async: true

  alias Fractal.Accounts.Services.AuthService

  describe "register_user/1" do
    test "registra un usuario y retorna token" do
      attrs = %{
        email: "test@uni.com",
        password: "12345678",
        first_name: "Test",
        last_name: "User"
      }

      assert {:ok, user, token} = AuthService.register_user(attrs)
      assert user.email == attrs.email
      assert is_binary(token)
      assert user.role == :student
    end
  end

  describe "authenticate/2" do
    test "autentica usuario existente" do
      attrs = %{
        email: "test@uni.com",
        password: "12345678",
        first_name: "Test",
        last_name: "User"
      }

      {:ok, user, _token} = AuthService.register_user(attrs)

      assert {:ok, ^user, token} = AuthService.authenticate(attrs.email, attrs.password)
      assert is_binary(token)
    end

    test "falla con credenciales incorrectas" do
      assert {:error, :invalid_credentials} = AuthService.authenticate("bad@uni.com", "wrongpass")
    end
  end
end
