defmodule Web.MapController do
  use Web, :controller

  alias Web.AccidentQuery
  alias Web.AccidentForm

  def data(conn, %{"q" => query}) do
    case AccidentForm.validate(query) do
      {:ok, filter} ->
        accidents = AccidentQuery.filter(filter)
        json(conn, accidents)

      {:error, _invalid_changeset} ->
        json(conn, AccidentQuery.default())
    end
  end

  def data(conn, _params), do: json(conn, AccidentQuery.default())

  def index(conn, _params), do: render(conn, "index.html", form: AccidentForm.new())
end
