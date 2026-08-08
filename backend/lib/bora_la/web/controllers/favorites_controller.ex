defmodule BoraLaWeb.FavoritesController do
  use Phoenix.Controller, namespace: BoraLaWeb

  def index(conn, _params) do
    json(conn, %{
      data: [
        %{
          id: "fav_01",
          event_id: "evt_001",
          user_id: "user_001",
          name: "Sábado de Música ao Vivo",
          location: "Bar do Bairro"
        }
      ]
    })
  end

  def create(conn, %{"event_id" => event_id, "name" => name, "location" => location}) do
    json(conn, %{
      id: "fav_new",
      event_id: event_id,
      user_id: "user_001",
      name: name,
      location: location
    })
  end
end
