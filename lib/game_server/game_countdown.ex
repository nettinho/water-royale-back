defmodule GameServer.GameCountdown do
    use GenServer

    alias GameServerWeb.Endpoint
    alias GameServerWeb.GameChannel
  
    def init(game_id) do
      schedule_starting()
      {:ok, {game_id, 3}}
    end
  
    def handle_info(:countdown, {game_id, count}) do
      Endpoint.broadcast "game:" <> game_id, "updated_countdown", %{"count" => count}
      case count do
        0 -> 
          GameChannel.activate_sockets(game_id)
          schedule_valve_spawner()
        _ -> schedule_starting()
      end
      {:noreply, {game_id, count - 1}}
    end

    def handle_info(:spawn_valve, {game_id, _}) do
      GameChannel.broadcast_valves(game_id)
      schedule_valve_spawner()
      {:noreply, {game_id, 0}}
    end
  
    defp schedule_starting() do
      Process.send_after(self(), :countdown, 1_000)
    end
    defp schedule_valve_spawner() do
      Process.send_after(self(), :spawn_valve, 1_500)
    end
  end