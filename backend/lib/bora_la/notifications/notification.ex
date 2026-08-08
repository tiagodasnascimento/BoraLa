defmodule BoraLa.Notifications.Notification do
  @moduledoc false

  defstruct [:id, :title, :message, :created_at]

  def new(attrs) do
    %__MODULE__{
      id: Map.get(attrs, :id),
      title: Map.get(attrs, :title),
      message: Map.get(attrs, :message),
      created_at: Map.get(attrs, :created_at, DateTime.utc_now())
    }
  end
end
