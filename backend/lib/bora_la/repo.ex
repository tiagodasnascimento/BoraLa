defmodule BoraLa.Repo do
  use Ecto.Repo,
    otp_app: :bora_la,
    adapter: Ecto.Adapters.Postgres
end
