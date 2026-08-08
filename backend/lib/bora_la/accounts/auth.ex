defmodule BoraLa.Accounts.Auth do
  @moduledoc false

  alias BoraLa.Accounts.User

  def login(email, password) when is_binary(email) and is_binary(password) do
    if email == "" or password == "" do
      {:error, :invalid_credentials}
    else
      {:ok,
       %User{
         id: "user_001",
         email: email,
         name: "Usuário BoraLá"
       }}
    end
  end

  def login(_email, _password), do: {:error, :invalid_credentials}
end
