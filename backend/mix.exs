defmodule BoraLa.MixProject do
  use Mix.Project

  def project do
    [
      app: :bora_la,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {BoraLa.Application, []}
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7.11"},
      {:phoenix_pubsub, "~> 2.1"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.5"},
      {:postgrex, "~> 0.17"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
