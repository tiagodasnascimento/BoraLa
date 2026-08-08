defmodule BoraLa.Favorites.Favorite do
  @moduledoc false

  defstruct [:id, :event_id, :user_id, :name, :location]

  def new(attrs) do
    %__MODULE__{
      id: Map.get(attrs, :id),
      event_id: Map.get(attrs, :event_id),
      user_id: Map.get(attrs, :user_id),
      name: Map.get(attrs, :name),
      location: Map.get(attrs, :location)
    }
  end
end
