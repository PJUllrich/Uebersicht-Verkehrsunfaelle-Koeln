defmodule Web.AnalyseLive do
  use Web, :live_view

  alias Web.AnalyseForm

  @impl true
  def render(assigns), do: Web.AnalyseView.render("index.html", assigns)

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :form, AnalyseForm.new())}
  end

  @impl true
  def handle_event("fetch", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end
end
