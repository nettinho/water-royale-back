defmodule GameServer.Games do
  alias GameServer.Game
  alias GameServerWeb.GameChannel
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, fn(games) -> games end)
  end

  def get(game_id) do
    Agent.get(__MODULE__, fn(games) -> Enum.find(games, fn(g) -> g.id == game_id end) end)
  end

  def create(id, active_count) do
    game = Game.new(id, active_count)
    Agent.update(__MODULE__, fn(games) -> [game|games] end)
    game
  end

  def update(games) do
    Agent.update(__MODULE__, fn(_) -> games end)
  end

  def update_game(game_id, fn_update) do
    Agent.update(__MODULE__, fn(games) -> 
      Enum.map(games, fn g -> 
        case g.id do
          ^game_id -> fn_update.(g)
          _ -> g
        end
      end)
    end)
  end

  def add_player(id, player, channel, on_game_full) do
    update_game(id, fn g -> 
      game = Map.update!(g, :players, fn players -> players ++ [player] end)
      %{players: players, active_count: active_count} = game
      case length(players) == active_count do
        true -> on_game_full.(game, channel)
        _ -> game
      end
    end)
  end

  def get_player(id, player_id) do
    Agent.get(__MODULE__, fn(games) -> 
      games
      |> Enum.find(fn(g) -> g.id == id end)
      |> Map.get(:players)
      |> Enum.find(fn(p) -> p.id == player_id end)
    end)
  end

  def get_and_update_player(id, player_id, update_fn) do
    Agent.get_and_update(__MODULE__, fn(games) -> 
      players = games
      |> Enum.find(fn(g) -> g.id == id end)
      |> Map.get(:players)

      player = players
      |> Enum.find(fn(p) -> p.id == player_id end)
      |> update_fn.()

      players = players
      |> Enum.map(fn p -> 
        case Map.get(p, :id) do
          ^player_id -> player
          _ -> p
        end
      end)
      
      games = Enum.map(games, fn g -> 
        case g.id do
          ^id -> Map.put(g, :players, players)
          _ -> g
        end
      end)
      {player, games}
    end)
  end

  def user_terminate(game_id, player_id) do
    Agent.get_and_update(__MODULE__, fn(games) -> 
      {player, attacker, games} = kill_player(games, game_id, player_id)
      {{player, attacker}, games}
    end)
  end


  defp kill_player(games, game_id, player_id) do
    game = Enum.find(games, fn(g) -> g.id == game_id end)
    players = game.players
    player = players
    |> Enum.find(fn(p) -> p.id == player_id end)
    |> Map.put(:life, 0)
    attacker = players
    |> Enum.find(fn(p) -> p.target == player_id end)
    |> Map.put(:target, player.target)

    GameChannel.set_socket_active(game_id, player.id, false)
    if game.active_count == 1 do
      GenServer.stop(game.pid)
    end

    attacker_id = attacker.id
    players = Enum.map(players, fn p -> 
      case p.id do
        ^player_id -> player
        ^attacker_id -> attacker
        _ -> p
      end
    end)
    games = Enum.map(games, fn g -> 
      case g.id do
        ^game_id -> g
          |> Map.put(:players, players)
          |> Map.update!(:active_count, &(&1 - 1) )
        _ -> g
      end
    end)
    {player, attacker, games}
  end
end
