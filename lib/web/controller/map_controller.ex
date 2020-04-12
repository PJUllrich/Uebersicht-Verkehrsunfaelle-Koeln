defmodule Web.MapController do
  use Web, :controller

  alias Web.AccidentQuery

  def index(conn, _params) do
    accidents = AccidentQuery.all()
    render(conn, "index.html", accidents: accidents)
  end
end
