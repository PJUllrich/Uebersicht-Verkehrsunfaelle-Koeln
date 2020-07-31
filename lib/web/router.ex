defmodule Web.Router do
  use Web, :router
  import Plug.BasicAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(AnalyticsEx.Plugs.CountRequestsPerPath)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :admins_only do
    plug(:basic_auth,
      username: Application.get_env(:app, :basic_auth)[:username],
      password: Application.get_env(:app, :basic_auth)[:password]
    )
  end

  scope "/", Web do
    pipe_through(:browser)

    get("/", MapController, :index)
    post("/api/list", MapController, :data_fallback)
  end

  scope "/api", Web do
    pipe_through(:api)

    get("/list", MapController, :data)
  end

  scope "/" do
    pipe_through([:browser, :admins_only])

    live_dashboard("/dashboard",
      metrics: Web.Telemetry,
      metrics_history: {LiveDashboardHistory, :metrics_history, [__MODULE__]}
    )
  end
end
