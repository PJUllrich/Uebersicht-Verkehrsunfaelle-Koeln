defmodule Web.Router do
  use Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", Web do
    pipe_through(:browser)

    get("/", MapController, :index)
    post("/api/list", MapController, :data_fallback)
  end

  scope "/api", Web do
    pipe_through(:api)

    get("/list", MapController, :data)
    get("/ping", PingController, :ping)
  end
end
