defmodule BoraLaWeb.AuthController do
  use Phoenix.Controller, namespace: BoraLaWeb

  alias BoraLa.Accounts.Auth

  def login(conn, %{"email" => email, "password" => password}) do
    case Auth.login(email, password) do
      {:ok, user} ->
        json(conn, %{user: %{id: user.id, name: user.name, email: user.email}})

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "invalid_credentials"})
    end
  end
end
