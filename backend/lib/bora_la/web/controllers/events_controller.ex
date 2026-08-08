defmodule BoraLaWeb.EventsController do
  use Phoenix.Controller, namespace: BoraLaWeb

  def index(conn, _params) do
    json(conn, %{
      data: [
        %{
          id: "evt_001",
          name: "Sábado de Música ao Vivo",
          category: "Música",
          venue_id: "venue_001",
          start_at: "2026-08-07T20:00:00Z",
          end_at: "2026-08-07T23:30:00Z"
        }
      ]
    })
  end

  def show(conn, %{"id" => id}) do
    json(conn, %{
      id: id,
      name: "Sábado de Música ao Vivo",
      category: "Música",
      venue_id: "venue_001",
      start_at: "2026-08-07T20:00:00Z",
      end_at: "2026-08-07T23:30:00Z",
      description: "Show com banda local e drinks especiais."
    })
  end
end
