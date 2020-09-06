defmodule Web.AnalyseForm do
  use Web, :form_object

  @default_values %{years: [2019]}

  @primary_key false
  embedded_schema do
    field(:years, {:array, :integer})
  end

  def new(query \\ @default_values),
    do: %@me{} |> do_cast(query)

  def default() do
    new()
    |> do_cast(%{})
    |> apply_action!(:insert)
  end

  def validate(params \\ %{}) do
    new(%{})
    |> do_cast(params)
    |> apply_action(:insert)
  end

  defp do_cast(form, params), do: form |> cast(params, [:years])
end
