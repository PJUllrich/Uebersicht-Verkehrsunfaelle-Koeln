# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

config :app, App.Repo,
  ssl: true,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "3")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :app, Web.Endpoint, secret_key_base: secret_key_base

live_view_signing_salt =
  System.get_env("LIVE_VIEW_SIGNING_SALT") ||
    raise """
    environment variable LIVE_VIEW_SIGNING_SALT is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :app, Web.Endpoint,
  live_view: [
    signing_salt: live_view_signing_salt
  ]

_map_box_token =
  System.get_env("MAPBOX_ACCESS_TOKEN") ||
    raise """
    environment variable MAPBOX_ACCESS_TOKEN is missing.
    You can get one on the Mapbox Website.
    """

basic_auth_username =
  System.get_env("ADMIN_USERNAME") ||
    raise """
    environment variable ADMIN_USERNAME is missing.
    You can generate one by calling: mix phx.gen.secret
    """

basic_auth_password =
  System.get_env("ADMIN_PASSWORD") ||
    raise """
    environment variable ADMIN_PASSWORD is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :app, :basic_auth,
  username: basic_auth_username,
  password: basic_auth_password

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :app, Web.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
