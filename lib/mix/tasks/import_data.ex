defmodule Mix.Tasks.ImportData do
  use Mix.Task

  require Logger

  def run(path) do
    Mix.Task.run("app.start", [])

    App.Repo.delete_all(App.Accident)

    File.stream!(path, [:trim_bom])
    |> CSV.decode!(separator: ?;)
    |> Enum.each(&create_accident/1)
  end

  defp create_accident([year, latitude, longitude, vb1, vb2]) do
    attrs = %{
      year: year,
      latitude: latitude |> String.replace(",", "."),
      longitude: longitude |> String.replace(",", "."),
      vb1: vb1,
      vb2: vb2
    }

    %App.Accident{}
    |> App.Accident.changeset(attrs)
    |> insert_changeset()
  end

  defp insert_changeset(%Ecto.Changeset{valid?: true} = changeset),
    do: App.Repo.insert!(changeset)

  defp insert_changeset(%Ecto.Changeset{valid?: false} = changeset),
    do: Logger.warn(changeset.errors)
end
