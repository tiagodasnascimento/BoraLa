defmodule BoraLaWeb.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BoraLaWeb do
    pipe_through :api

    get "/health", HealthController, :index
    post "/login", AuthController, :login
    get "/events", EventsController, :index
    get "/events/:id", EventsController, :show
    get "/venues/:id", VenuesController, :show
    get "/venues/:id/status", VenuesController, :status
    get "/traffic/:id", TrafficController, :show
    get "/favorites", FavoritesController, :index
    post "/favorites", FavoritesController, :create
    get "/notifications", NotificationsController, :index
    get "/recommendations", RecommendationsController, :index
    get "/search", SearchController, :index
  end
end
