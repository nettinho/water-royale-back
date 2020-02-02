defmodule GameServerWeb.LobbyChannel do
  @moduledoc """
  """

  use Phoenix.Channel, hibernate_after: :infinity

  alias GameServer.Games
  alias GameServer.LobbyGame
  alias GameServer.LobbyGames
  alias GameServer.LobbyPlayer
  alias GameServer.LobbyPlayers
  
  def join("server:lobby", %{"username" => username}, socket) do
    players = LobbyPlayers.get()
    case username_being_used(players, username) do
      false ->
        player = LobbyPlayers.add(username)
        socket = assign(socket, :user, player.id)
        send self(), {:after_join_lobby, player}

        {:ok, socket}
      _ -> {:error, %{reason: :username_not_available}}
    end
  end

  defp username_being_used(_, _), do: false
  defp username_being_used(players, username) do
    players
    |> Enum.map(&(Map.get(&1, :username)))
    |> Enum.member?(username)
  end

  def handle_info({:after_join_lobby, player}, socket) do
    games = Enum.map(LobbyGames.get(), &LobbyGame.render/1)
    push socket, "after_join_lobby", %{
      "player" => LobbyPlayer.render(player),
      "games" => games
    }
    {:noreply, socket}
  end

  def terminate(_, socket) do
    case LobbyGames.get_game_of_user(socket.assigns.user) do
      %{id: game_id} ->
        handle_in("leave_game", %{"id" => game_id}, socket)
      _ ->
    end
  end

  def handle_in("create_game", _, socket) do
    player_id = socket.assigns.user
    %{username: username} = LobbyPlayers.get(player_id)
    game_name = "Game of " <> username
    game = LobbyGames.create(game_name)

    broadcast socket, "new_game_lobby", %{"game" => LobbyGame.render(game)}
    handle_in("join_game", %{"id" => game.id}, socket)

    {:noreply, socket}
  end

  def handle_in("join_game", %{"id" => game_id}, socket) do
    game = LobbyGames.get(game_id)
    player = socket.assigns.user
    |> LobbyPlayers.get
    |> LobbyPlayer.render

    game_players = Map.get(game, :players) ++ [player]
    game = LobbyGames.get_and_update_game(game_id, fn g ->
      g
      |> Map.put(:players, game_players)
      |> Map.put(:all_ready, false)
    end)

    broadcast socket, "joined_game_lobby", %{
      "game" => LobbyGame.render(game),
      "player" => player
    }

    {:noreply, socket}
  end

  def handle_in("ready_game", %{"id" => game_id}, socket) do
    game = LobbyGames.get(game_id)
    player_id = socket.assigns.user
    player = player_id
    |> LobbyPlayers.get
    |> LobbyPlayer.render

    game_players = game
    |> Map.get(:players)
    |> Enum.map(&( case Map.get(&1, "id") do
      ^player_id -> Map.update!(&1, "ready", fn r -> not r end)
      _ -> &1
    end))
    all_ready = Enum.reduce(game_players, true, fn %{"ready" => ready}, acc -> acc and ready end)
    game = LobbyGames.get_and_update_game(game_id, fn g -> 
      g
      |> Map.put(:players, game_players)
      |> Map.put(:all_ready, all_ready)
    end)
    broadcast socket, "updated_game_lobby", %{"game" => LobbyGame.render(game)}

    {:noreply, socket}
  end

  def handle_in("leave_game", %{"id" => game_id}, socket) do
    game = LobbyGames.get(game_id)
    player_id = socket.assigns.user
    player = player_id
    |> LobbyPlayers.get
    |> LobbyPlayer.render

    game_players = game
    |> Map.get(:players)
    |> Enum.reject(&( Map.get(&1, "id") == player_id))
    all_ready = Enum.reduce(game_players, true, fn %{"ready" => ready}, acc -> acc and ready end)
    game = LobbyGames.get_and_update_game(game_id, fn g -> 
      g
      |> Map.put(:players, game_players)
      |> Map.put(:all_ready, all_ready)
    end)

    broadcast socket, "left_game_lobby", %{
      "game" => LobbyGame.render(game),
      "player" => player
    }

    if length(game_players) == 0 do
      LobbyGames.delete_game(game_id)
    end

    {:noreply, socket}
  end

  def handle_in("start_game", %{"id" => game_id}, socket) do
    active_count = game_id
    |> LobbyGames.get
    |> Map.get(:players)
    |> length()
    
    Games.create(game_id, active_count)
    LobbyGames.delete_game(game_id)

    broadcast socket, "starting_game", %{"game_id" => game_id}

    {:noreply, socket}
  end
  
end
