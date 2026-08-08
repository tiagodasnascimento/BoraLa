defmodule BoraLaWeb.TrafficController do
  use Phoenix.Controller, namespace: BoraLaWeb

  alias BoraLa.Traffic.Status

  def show(conn, %{"id" => id}) do
    status = Status.new(id, 160, 200)

    json(conn, %{
      venue_id: status.venue_id,
      status: status.status,
      occupancy: status.occupancy,
      capacity: status.capacity,
      updated_at: status.updated_at
    })
  end
end
