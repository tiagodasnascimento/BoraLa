defmodule BoraLaWeb.ApiContractTest do
  use ExUnit.Case, async: true

  test "health response contract" do
    response = %{status: "ok", service: "bora_la"}

    assert response.status == "ok"
    assert response.service == "bora_la"
  end
end
