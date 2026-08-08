import Config

config :bora_la,
  ecto_repos: [BoraLa.Repo]

config :bora_la, BoraLa.Repo,
  database: "bora_la_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  pool_size: 10

config :bora_la, BoraLaWeb.Endpoint,
  url: [host: "localhost", port: 4000],
  http: [ip: {127, 0, 0, 1}, port: 4000],
  server: true

config :logger, level: :info
