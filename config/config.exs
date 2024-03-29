# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :app,
  ecto_repos: [App.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :app, Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WtBz4ReOazDThcvxYei1aGrZiDxpBhwKhFB/fhGYXdD3iDzB0Ap+hjNQY4H8ZQdh",
  render_errors: [view: Web.ErrorView, accepts: ~w(html json)],
  pubsub_server: App.PubSub

config :esbuild,
  version: "0.16.4",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
