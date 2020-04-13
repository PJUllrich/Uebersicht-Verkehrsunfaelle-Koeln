defmodule Web.MapController do
  use Web, :controller

  alias Web.AccidentQuery
  alias Web.AccidentForm

  def index(conn, %{"q" => query}) do
    case AccidentForm.validate(query) do
      {:ok, filter} ->
        accidents = AccidentQuery.filter(filter)
        render(conn, "index.html", accidents: accidents, form: AccidentForm.new(query))

      {:error, invalid_changeset} ->
        accidents = AccidentQuery.default()
        render(conn, "index.html", accidents: accidents, form: invalid_changeset)
    end
  end

  def index(conn, params) do
    IO.inspect(params)
    form = AccidentForm.new()
    accidents = AccidentQuery.default()
    render(conn, "index.html", accidents: accidents, form: form)
  end
end
