# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :game_server,
  ecto_repos: [GameServer.Repo]

# Configures the endpoint
config :game_server, GameServerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "djmQEYFjKuKgH2ujHdiC+Dh4TGCBOKM5ep0Di2jlJ3DcEwkgLKt1Uu3q+ajZous4",
  render_errors: [view: GameServerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GameServer.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
level: :info,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
