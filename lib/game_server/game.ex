defmodule GameServer.Game do
  @moduledoc """
  """

  alias GameServer.Player

  defstruct(
    id: 0,
    players: [],
    pid: nil,
    active_count: 0
  )

  def new(id, active_count) do
    %__MODULE__{id: id, active_count: active_count}
  end

  def render(%__MODULE__{id: id, active_count: active_count, players: players}) do
    %{
      "id" => id,
      "active_count" => active_count,
      "players" => Enum.map(players, &Player.render/1)
    }
  end
end