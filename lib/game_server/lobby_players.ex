defmodule GameServer.LobbyPlayers do
  alias GameServer.LobbyPlayer
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, fn(players) -> players end)
  end

  def get(user_id) do
    Agent.get(__MODULE__, fn(players) -> Enum.find(players, fn(p) -> p.id == user_id end) end)
  end

  def add(username) do
    player = LobbyPlayer.new(username)
    Agent.update(__MODULE__, fn(players) -> players ++ [player] end)
    player
  end
end
