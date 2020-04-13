defmodule Web.AccidentQuery do
  import Ecto.Query
  alias App.{Accident, Repo}

  def default() do
    %{
      years: [2017],
      vb1: nil,
      vb2: nil
    }
    |> filter()
  end

  def filter(filter) do
    from(a in Accident)
    |> with_filter(:years, filter.years)
    |> with_filter(:vb1, filter.vb1)
    |> with_filter(:vb2, filter.vb2)
    |> select([a], [a.longitude, a.latitude])
    |> Repo.all()
    |> to_geojson()
  end

  defp with_filter(query, :years, nil), do: query

  defp with_filter(query, :years, years) do
    from(
      a in query,
      where: a.year in ^years
    )
  end

  defp with_filter(query, :vb1, nil), do: query

  defp with_filter(query, :vb1, vb1) do
    from(
      a in query,
      where: a.vb1 in ^vb1
    )
  end

  defp with_filter(query, :vb2, nil), do: query

  defp with_filter(query, :vb2, vb2) do
    from(
      a in query,
      where: a.vb2 in ^vb2
    )
  end

  defp to_geojson(accidents) do
    features =
      for [long, lat] <- accidents,
          do: %{type: "Feature", geometry: %{type: "Point", coordinates: [long, lat]}}

    %{type: "FeatureCollection", features: features}
  end
end
