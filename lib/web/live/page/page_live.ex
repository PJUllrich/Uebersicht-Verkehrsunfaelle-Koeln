defmodule Web.PageLive do
  use Web, :live_view

  def render(assigns) do
    Phoenix.View.render(Web.PageView, "index.html", assigns)
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
