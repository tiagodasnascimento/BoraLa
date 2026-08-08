defmodule BoraLaWeb.VenuesController do
  use Phoenix.Controller, namespace: BoraLaWeb

  def show(conn, %{"id" => id}) do
    json(conn, %{
      id: id,
      name: "Bar do Bairro",
      category: "Bar",
      city: "Fortaleza",
      neighborhood: "Meireles",
      address: "Rua das Flores, 120"
    })
  end

  def status(conn, %{"id" => id}) do
    json(conn, %{
      venue_id: id,
      status: "alta",
      capacity: 200,
      occupancy: 160,
      updated_at: "2026-08-07T19:45:00Z"
    })
  end
end
