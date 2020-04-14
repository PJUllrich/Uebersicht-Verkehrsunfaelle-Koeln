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

  # Some Browser don't support intercepting a form submit
  # and will perform a POST to the /api/list endpoint.
  # We intercept this request here and redirect to the index page
  # which injects the query url to the MapBox GL JS library.
  def data_fallback(conn, %{"q" => query}),
    do: redirect(conn, to: Routes.map_path(conn, :index, q: query))

  def index(conn, %{"q" => query}) do
    endpoint = Routes.map_url(conn, :data, q: query)
    render(conn, "index.html", form: AccidentForm.new(query), endpoint: endpoint)
  end

  def index(conn, _params), do: render(conn, "index.html", form: AccidentForm.new())
end
