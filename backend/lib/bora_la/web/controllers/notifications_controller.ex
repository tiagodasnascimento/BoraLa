defmodule BoraLaWeb.NotificationsController do
  use Phoenix.Controller, namespace: BoraLaWeb

  def index(conn, _params) do
    json(conn, %{
      data: [
        %{
          id: "nt_01",
          title: "Evento em destaque",
          message: "Sábado de Música ao Vivo começa em 2 horas.",
          created_at: "2026-08-07T19:00:00Z"
        },
        %{
          id: "nt_02",
          title: "Movimentação alta",
          message: "Bar do Bairro está com movimento intenso neste momento.",
          created_at: "2026-08-07T18:30:00Z"
        }
      ]
    })
  end
end
