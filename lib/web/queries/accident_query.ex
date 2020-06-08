defmodule Web.AccidentQuery do
  import Ecto.Query
  alias App.{Accident, Repo}

  import App.Accident, only: [map_to_cat: 1]

  def filter(filter) do
    from(a in Accident)
    |> with_filter(:years, filter.years)
    |> with_filter(:vb1, filter.vb1)
    |> with_filter(:vb2, filter.vb2)
    |> with_filter(:categories, filter.categories)
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

  defp with_filter(query, :categories, nil), do: query

  defp with_filter(query, :categories, categories) do
    from(
      a in query,
      where: a.category in ^categories
    )
  end

  defp to_geojson(accidents) do
    features =
      for acc <- accidents,
          do: %{
            type: "Feature",
            geometry: %{type: "Point", coordinates: [acc.longitude, acc.latitude]},
            properties: %{
              vb1: map_to_cat(acc.vb1),
              vb2: map_to_cat(acc.vb2),
              category: acc.category
            }
          }

    %{type: "FeatureCollection", features: features}
  end
end
