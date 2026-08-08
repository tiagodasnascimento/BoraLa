defmodule BoraLaWeb.HealthController do
  use Phoenix.Controller, namespace: BoraLaWeb

  def index(conn, _params) do
    json(conn, %{status: "ok", service: "bora_la"})
  end
end
