use Mix.Config

# Configure your database
config :game_server, GameServer.Repo,
  username: "postgres",
  password: "postgres",
  database: "game_server_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :game_server, GameServerWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
