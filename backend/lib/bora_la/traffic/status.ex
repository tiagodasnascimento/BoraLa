defmodule BoraLa.Traffic.Status do
  @moduledoc false

  defstruct [:venue_id, :status, :occupancy, :capacity, :updated_at]

  def new(venue_id, occupancy, capacity) do
    %__MODULE__{
      venue_id: venue_id,
      occupancy: occupancy,
      capacity: capacity,
      updated_at: DateTime.utc_now(),
      status: classify(occupancy, capacity)
    }
  end

  defp classify(occupancy, capacity) do
    ratio = occupancy / max(capacity, 1)

    cond do
      ratio < 0.35 -> :low
      ratio < 0.7 -> :medium
      ratio < 0.9 -> :high
      true -> :crowded
    end
  end
end
