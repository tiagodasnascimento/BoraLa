defmodule BoraLa.NotificationsRecommendationsTest do
  use ExUnit.Case, async: true

  test "notification payload includes required fields" do
    payload = %{
      id: "nt_01",
      title: "Evento em destaque",
      message: "Sábado de Música ao Vivo começa em 2 horas.",
      created_at: "2026-08-07T19:00:00Z"
    }

    assert payload.id == "nt_01"
    assert payload.title == "Evento em destaque"
  end

  test "recommendation payload includes score and reason" do
    payload = %{
      event_id: "evt_001",
      score: 0.92,
      reason: "Você costuma curtir música ao vivo em bairros próximos."
    }

    assert payload.event_id == "evt_001"
    assert payload.score == 0.92
  end
end
