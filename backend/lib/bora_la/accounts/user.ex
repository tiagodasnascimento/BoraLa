defmodule BoraLa.Accounts.User do
  @moduledoc false

  defstruct [:id, :email, :name]

  def new(attrs) do
    %__MODULE__{
      id: Map.get(attrs, :id),
      email: Map.get(attrs, :email),
      name: Map.get(attrs, :name)
    }
  end
end
