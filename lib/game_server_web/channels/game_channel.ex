defmodule GameServerWeb.GameChannel do
  @moduledoc """
  """

  use Phoenix.Channel

  alias GameServer.Game
  alias GameServer.GameCountdown
  alias GameServer.Games
  alias GameServer.LobbyGames
  alias GameServer.LobbyPlayers
  alias GameServer.Player
  alias GameServerWeb.Endpoint

  def join("game:" <> game_id, %{"id" => user_id}, socket) do
    socket = socket
    |> assign(:user, user_id)
    |> assign(:game, game_id)
    |> assign(:active, false)

    player = user_id
    |> LobbyPlayers.get
    |> Player.new

    Games.add_player(game_id, player, self(), &on_game_full/2)
    Endpoint.subscribe("game:#{game_id}:#{user_id}")

    {:ok, socket}
  end

  defp on_game_full(%{id: id, players: players} = game, channel) do

    first_id = Enum.at(players, 0).id
    players = players
    |> update_player_target(first_id)

    {:ok, pid} = GenServer.start_link(GameCountdown, id)
    game = game
    |> Map.put(:players, players)
    |> Map.put(:pid, pid)
    send channel, {:broadcast_game_start, game}
    game
  end

  defp update_player_target([head | []], first_id) do
    head = %{head | target: first_id}
    [head | []]
  end
  defp update_player_target([head | [next_head | tail]], first_id) do
    head = %{head | target: next_head.id}
    [head | update_player_target([next_head | tail], first_id)]
  end

  def handle_info({:broadcast_game_start, game}, socket) do
    broadcast socket, "updated_game", Game.render(game)
    {:noreply, socket}
  end

  def activate_sockets(game_id) do
    game_id
    |> Games.get
    |> Map.get(:players)
    |> Enum.each(fn p -> set_socket_active(game_id, p.id, true) end)
  end

  def set_socket_active(game_id, player_id, active) do
    Endpoint.broadcast("game:#{game_id}:#{player_id}", "set_active", %{"active" => active})
  end

  def handle_info(%{event: "set_active", payload: %{"active" => active}}, socket) do
    {:noreply, assign(socket, :active, active)}
  end

  # Do nothing on non-active sockets
  def handle_in(_, _, %{assigns: %{active: false}} = socket), do: {:noreply, socket}

  def handle_in("update", %{
    "transformation" => transformation,
    "water_level" => water_level,
    "action" => action
  }, socket) do
    player = Games.get_player(
      socket.assigns.game,
      socket.assigns.user
    )

    if player.action != action do
      IO.inspect "action change #{inspect action}"
      if action == -1 do
        handle_in("release_valve", %{
          "type" => player.action
        }, socket)
      else
        handle_in("hitting_valve", %{
          "type" => action
        }, socket)
      end
    end

    player = Games.get_and_update_player(
      socket.assigns.game,
      socket.assigns.user,
      fn(p) -> 
        p
        |> Map.put(:transformation, transformation)
        |> Map.put(:water_level, water_level)
        |> Map.put(:action, action)
      end
    )
    
    broadcast socket, "updated_player", Player.render(player)

    {:noreply, socket}
  end

  def handle_in("update", %{
    "transformation" => transformation,
    "water_level" => water_level
  }, socket) do

    player = Games.get_and_update_player(
      socket.assigns.game,
      socket.assigns.user,
      fn(p) -> 
        p
        |> Map.put(:transformation, transformation)
        |> Map.put(:water_level, water_level)
      end
    )
    
    broadcast socket, "updated_player", Player.render(player)

    {:noreply, socket}
  end

  def handle_in("die", _, socket) do
    game_id = socket.assigns.game
    user_id = socket.assigns.user
    games = Games.get()
    {player, attacker, games} = Games.kill_player(games, game_id, user_id)

    Games.update(games)
    
    broadcast socket, "updated_player", Player.render(attacker)
    broadcast socket, "updated_player", Player.render(player)

    {:noreply, socket}
  end

  def handle_in("hitting_valve", %{
    "type" => valve_type
  }, socket) do
    player = Games.get_and_update_player(
      socket.assigns.game,
      socket.assigns.user,
      fn(p) -> p
        |> Map.update!(:water_rate,  fn r -> 
          case valve_type do
            0 -> r - 1
            1 -> r + 1
            _ -> r 
          end
        end)
        |> Map.update!(:crack_count,  fn c -> 
          case valve_type do
            2 -> c - 1
            _ -> c
          end
        end)
      end
    )
    target_id = player.target
    target = Games.get_and_update_player(
      socket.assigns.game,
      target_id,
      fn(p) -> Map.update!(p, :water_rate,  fn r -> 
        case valve_type do
          0 -> r + 1
          1 -> r - 1
          _ -> r 
        end
      end)
    end)
    broadcast socket, "updated_player", Player.render(player)
    broadcast socket, "updated_player", Player.render(target)

    {:noreply, socket}
  end

  def handle_in("release_valve", %{
    "type" => valve_type
  }, socket) do
    player = Games.get_and_update_player(
      socket.assigns.game,
      socket.assigns.user,
      fn(p) -> Map.update!(p, :water_rate,  fn r -> 
        case valve_type do
          0 -> r + 1
          1 -> r - 1
          _ -> r 
        end
      end)
      end
    )
    target_id = player.target
    target = Games.get_and_update_player(
      socket.assigns.game,
      target_id,
      fn(p) -> Map.update!(p, :water_rate,  fn r -> 
        case valve_type do
          0 -> r - 1
          1 -> r + 1
          _ -> r 
        end
      end)
    end)
    broadcast socket, "updated_player", Player.render(player)
    broadcast socket, "updated_player", Player.render(target)

    {:noreply, socket}
  end

  def broadcast_valves(game_id) do
    valve_type = Enum.random(0..2)
    valve_pos_x = Enum.random(-4..4) / 10.0
    valve = %{"type" => valve_type, "pos_x" => valve_pos_x}

    Endpoint.broadcast "game:" <> game_id, "spawn_valve", valve

    if valve_type == 2 do
      game_id 
      |> Games.get
      |> Map.get(:players)
      |> Enum.map(fn player -> 
          Games.get_and_update_player(
            game_id,
            player.id,
            fn(p) -> Map.update!(p, :crack_count, fn c -> c + 1 end) end
          )
        end)
      |> Enum.each(fn p -> Endpoint.broadcast "game:" <> game_id, "updated_player", Player.render(p) end)
    end
  end

  def terminate(_, socket) do
    {player, attacker} = Games.user_terminate(
      socket.assigns.game,
      socket.assigns.user
    )
    broadcast socket, "updated_player", Player.render(player)
    broadcast socket, "updated_player", Player.render(attacker)
  end
end
