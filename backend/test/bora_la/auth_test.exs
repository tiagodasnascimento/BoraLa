defmodule BoraLa.AuthTest do
  use ExUnit.Case, async: true

  alias BoraLa.Accounts.Auth

  test "login with valid credentials returns user" do
    assert {:ok, %{email: "user@example.com", name: "Usuário BoraLá"}} =
             Auth.login("user@example.com", "123456")
  end

  test "login with empty credentials returns error" do
    assert {:error, :invalid_credentials} = Auth.login("", "")
  end
end
