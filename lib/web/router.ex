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
  end

  scope "/api", Web do
    pipe_through(:api)

    get("/list", MapController, :data)
  end
end
