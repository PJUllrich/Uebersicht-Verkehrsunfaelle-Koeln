import Config

# Configure your database
config :app, App.Repo,
  username: "postgres",
  password: "postgres",
  database: "app_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :app, Web.Endpoint,
  http: [port: 4002],
  server: false

config :app, Web.Endpoint,
  live_view: [
    signing_salt: "4fLxm/G1MSuPevob6tkxRj7NrHQ+J8Jy"
  ]

# Print only warnings and errors during test
config :logger, level: :warn
