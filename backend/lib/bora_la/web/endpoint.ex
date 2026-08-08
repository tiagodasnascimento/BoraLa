defmodule BoraLaWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :bora_la

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:bora_la, :endpoint]
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug BoraLaWeb.Router
end
