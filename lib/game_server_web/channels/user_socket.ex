defmodule GameServerWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "server:lobby", GameServerWeb.LobbyChannel
  channel "game:*", GameServerWeb.GameChannel
  
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
