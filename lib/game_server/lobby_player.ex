defmodule GameServer.LobbyPlayer do
  @moduledoc """
  """

  defstruct id: 0, username: "", ready: false

  def new(username) do
    %__MODULE__{id: generate_id, username: username}
  end

  def update(player, key, value) do
    %{player | key => value}
  end

  def generate_id() do
    UUID.uuid4
  end

  def render(%__MODULE__{id: id, username: username, ready: ready}) do
    %{
      "id" => id,
      "username" => username,
      "ready" => ready
    }
  end
end
