defmodule Web.PageLiveTest do
  use Support.LiveViewCase, async: true

  alias Web.PageLive

  test "shows index", %{conn: conn} do
    page_live_path = Routes.live_path(@endpoint, PageLive)
    {:ok, _view, html} = live(conn, page_live_path)

    assert html =~ "Welcome to Phoenix"
  end
end
