defmodule Web.Queries.AnalyseQuery do
  use Web, :query

  def filter(filter) do
    from(a in Accident)
    |> with_filter(:years, filter.years)
    |> Repo.all()
  end

  defp with_filter(query, :years, nil), do: query

  defp with_filter(query, :years, years) do
    from(
      a in query,
      where: a.year in ^years
    )
  end
end
