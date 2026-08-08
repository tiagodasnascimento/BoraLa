defmodule BoraLaWeb.SearchController do
  use Phoenix.Controller, namespace: BoraLaWeb

  def index(conn, %{"query" => query}) do
    results =
      [
        %{id: "evt_001", name: "Sábado de Música ao Vivo", category: "Música"},
        %{id: "evt_003", name: "Noite de Jazz", category: "Música"},
        %{id: "evt_002", name: "Happy Hour Gourmet", category: "Gastronomia"}
      ]
      |> Enum.filter(fn item ->
        query == "" or String.contains?(String.downcase(item.name), String.downcase(query))
      end)

    json(conn, %{data: results})
  end
end
