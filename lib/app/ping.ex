defmodule App.Ping do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(args) do
    schedule_ping()
    {:ok, args}
  end

  @impl true
  def handle_info(:ping, state) do
    ping_server()
    schedule_ping()
    {:noreply, state}
  end

  defp schedule_ping do
    Process.send_after(self(), :ping, 1000 * 60 * Enum.random(5..15))
  end

  defp ping_server do
    ping_url = Web.Router.Helpers.ping_url(Web.Endpoint, :ping)
    %{body: body} = HTTPoison.get!(ping_url)
    Logger.info(body)
  end
end
