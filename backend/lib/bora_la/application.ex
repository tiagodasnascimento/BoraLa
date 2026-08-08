defmodule BoraLa.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BoraLa.Repo,
      BoraLaWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: BoraLa.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
