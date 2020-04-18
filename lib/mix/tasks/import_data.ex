defmodule Mix.Tasks.ImportData do
  use Mix.Task

  require Logger

  def run(path) do
    Mix.Task.run("app.start", [])

    App.Repo.delete_all(App.Accident)

    opts = App.Repo.config()
    {:ok, pid} = Postgrex.start_link(opts)

    Postgrex.transaction(pid, fn conn ->
      stream =
        Postgrex.stream(
          conn,
          "COPY accidents(id,year,latitude,longitude,category,vb1,vb2) FROM STDIN CSV HEADER ",
          []
        )

      Enum.into(File.stream!(path, [:trim_bom]), stream)
    end)
  end
end
