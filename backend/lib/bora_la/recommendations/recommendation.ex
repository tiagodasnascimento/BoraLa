defmodule BoraLa.Recommendations.Recommendation do
  @moduledoc false

  defstruct [:event_id, :score, :reason]

  def new(event_id, score, reason) do
    %__MODULE__{
      event_id: event_id,
      score: score,
      reason: reason
    }
  end
end
