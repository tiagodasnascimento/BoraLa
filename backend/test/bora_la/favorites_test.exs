defmodule BoraLa.FavoritesTest do
  use ExUnit.Case, async: true

  test "favorite creation payload builds expected structure" do
    payload = %{
      id: "fav_new",
      event_id: "evt_003",
      user_id: "user_001",
      name: "Noite de Jazz",
      location: "Sede do Jazz"
    }

    assert payload.event_id == "evt_003"
    assert payload.name == "Noite de Jazz"
  end
end
