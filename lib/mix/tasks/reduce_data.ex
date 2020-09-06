defmodule Mix.Tasks.ReduceData do
  use Mix.Task

  def run([path]) do
    output = File.stream!(".priv/13-20-deploy copy.csv", [:append, :utf8])

    path
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Stream.drop(915)
    |> Stream.with_index(178_302)
    |> Stream.map(&extract_data/1)
    |> Stream.filter(&(!is_nil(&1)))
    |> CSV.encode()
    |> Stream.into(output)
    |> Stream.run()
  end

  defp extract_data({row, idx}) do
    date = Timex.parse!(row["VU-Datum"], "{D}.{0M}.{YY}")

    if Timex.compare(date, ~D[2020-04-01]) != -1 do
      vb2 =
        case row["Ord02 VB"] do
          "" -> "0"
          vb2 -> vb2
        end

      [
        idx,
        row["\uFEFFJahr"],
        row["Latitude"],
        row["Longitude"],
        row["Unfallkategorie"],
        row["Ord01 VB"],
        vb2
      ]
    else
      nil
    end
  end
end
