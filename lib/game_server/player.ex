defmodule GameServer.Player do
  @moduledoc """
  """

  defstruct(
    id: 0,
    username: "",
    target: nil,
    transformation: nil,
    water_level: 0,
    water_rate: 0,
    crack_count: 0,
    action: -1,
  )

  def new(%{id: id, username: username}) do
    %__MODULE__{id: id, username: username}
  end

  def render(%__MODULE__{} = player) do
    %{
      "id" => player.id,
      "target" => player.target,
      "username" => player.username,
      "transformation" => player.transformation,
      "water_level" => player.water_level,
      "water_rate" => player.water_rate,
      "crack_count" => player.crack_count,
      "action" => player.action
    }
  end
end
