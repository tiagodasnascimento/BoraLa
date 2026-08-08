defmodule BoraLa.Search.SearchResult do
  @moduledoc false

  defstruct [:id, :name, :category]

  def new(id, name, category) do
    %__MODULE__{
      id: id,
      name: name,
      category: category
    }
  end
end
