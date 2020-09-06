defmodule Mix.Tasks.GeocodeData do
  use Mix.Task

  require Logger

  @azure_search_endpoint "https://atlas.microsoft.com/search/address/json"
  @ignore_before ~D[2020-04-01]
  @col %{
    stadtteil: 15,
    strasse_1: 16,
    strasse_2: 17,
    haus_nr: 18
  }

  def run([path]) do
    HTTPoison.start()
    open_file(path)
  end

  defp open_file(path) do
    output = File.stream!("output.csv", [:write, :utf8])

    path
    |> File.stream!()
    |> CSV.decode()
    |> Stream.with_index()
    |> Stream.map(&geocode_row/1)
    |> CSV.encode()
    |> Stream.into(output)
    |> Stream.run()
  end

  defp geocode_row({{:ok, row}, 0}) do
    row ++ ["Latitude", "Longitude"]
  end

  defp geocode_row({{:ok, row}, _idx}) do
    with {:ok, row} <- filter(row),
         {:ok, adresse} <- erstelle_adresse(row),
         {:ok, %{"lat" => lat, "lon" => lon}} <- get_location(adresse) do
      row ++ [lat, lon]
    else
      _error ->
        row ++ [0, 0]
    end
  end

  defp geocode_row(row) do
    Logger.error(row)
    row
  end

  defp filter([_jahr, datum | _] = row) do
    date = Timex.parse!(datum, "{D}.{0M}.{YY}")

    if Timex.compare(date, @ignore_before) != -1 do
      {:ok, row}
    else
      {:error, row}
    end
  end

  defp erstelle_adresse(row) do
    strasse_1 = Enum.at(row, @col.strasse_1)
    strasse_2 = Enum.at(row, @col.strasse_2)
    haus_nr = Enum.at(row, @col.haus_nr)
    stadtteil = Enum.at(row, @col.stadtteil)
    strasse = if haus_nr, do: "#{strasse_1} #{haus_nr}", else: "#{strasse_1} & #{strasse_2}"

    {:ok, "#{strasse}, #{stadtteil}, Köln"}
  end

  defp get_location(adresse) do
    params = %{
      query: adresse,
      "subscription-key": subscription_key(),
      "api-version": 1.0,
      countrySet: "DE",
      limit: 1,
      lat: 50.943344,
      long: 6.957017,
      radius: 20_000
    }

    with %{status_code: 200} = res <- HTTPoison.get!(@azure_search_endpoint, [], params: params),
         %{"results" => [%{"position" => position}]} <- Jason.decode!(res.body) do
      {:ok, position}
    else
      %{"results" => []} ->
        {:error, adresse}

      res ->
        error = res.body |> Jason.decode!()
        Logger.error(error)
        {:error, error}
    end
  end

  defp subscription_key do
    System.get_env("SUBSCRIPTION_KEY")
  end
end
