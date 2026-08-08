defmodule BoraLaWeb.RecommendationsController do
  use Phoenix.Controller, namespace: BoraLaWeb

  def index(conn, _params) do
    json(conn, %{
      data: [
        %{
          event_id: "evt_001",
          score: 0.92,
          reason: "Você costuma curtir música ao vivo em bairros próximos."
        },
        %{
          event_id: "evt_002",
          score: 0.81,
          reason: "Happy Hour Gourmet combina com seu histórico de eventos gastronômicos."
        }
      ]
    })
  end
end
