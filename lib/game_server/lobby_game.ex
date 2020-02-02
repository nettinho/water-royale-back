defmodule GameServer.LobbyGame do
  @moduledoc """
  """

  defstruct id: 0, name: "", players: [], all_ready: false

  def new(name) do
    id = generate_id()
    %__MODULE__{id: id, name: name}
  end

  def update(game, key, value) do
    %{game | key => value}
  end

  def generate_id() do
    UUID.uuid4
  end

  def render(%__MODULE__{id: id, name: name, players: players, all_ready: all_ready}) do
    %{
      "id" => id,
      "name" => name,
      "players" => players,
      "all_ready" => all_ready
    }
  end
end