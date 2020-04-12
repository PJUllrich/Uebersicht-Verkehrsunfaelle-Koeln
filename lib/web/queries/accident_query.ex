defmodule Web.AccidentQuery do
  import Ecto.Query
  alias App.{Accident, Repo}

  def all() do
    from(
      a in Accident,
      limit: 10_000,
      select: [a.longitude, a.latitude]
    )
    |> Repo.all()
  end
end
