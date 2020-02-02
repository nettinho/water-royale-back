defmodule GameServer.LobbyGames do
  alias GameServer.LobbyGame
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, fn(games) -> games end)
  end

  def get(game_id) do
    Agent.get(__MODULE__, fn(games) -> Enum.find(games, fn(g) -> g.id == game_id end) end)
  end

  def create(name) do
    game = LobbyGame.new(name)
    Agent.update(__MODULE__, fn(games) -> [game|games] end)
    game
  end

  def delete_game(game_id) do
    Agent.update(__MODULE__, fn(games) -> Enum.reject(games, fn g -> g.id == game_id end) end)
  end

  def get_game_of_user(user_id) do
    Agent.get(__MODULE__, fn(games) -> 
      Enum.find(games, fn(g) ->
        player = g
        |> Map.get(:players)
        |> Enum.find(fn p -> p["id"] == user_id end)
        case player do
          nil -> false
          _ -> true
        end
      end)
    end)
  end

  def get_and_update_game(id, update_fn) do
    Agent.get_and_update(__MODULE__, fn(games) -> 
      game = games
      |> Enum.find(fn(g) -> g.id == id end)
      |> update_fn.()

      games = Enum.map(games, fn g -> 
        case g.id do
          ^id -> game
          _ -> g
        end
      end)
      {game, games}
    end)
  end
end
