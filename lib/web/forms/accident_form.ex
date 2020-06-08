defmodule Web.AccidentForm do
  use Web, :form_object

  import App.Accident, only: [map_cat: 1]

  @default_values %{years: [2019], vb1: [1, 3], vb2: [1, 3], categories: [1, 2, 3]}

  @primary_key false
  embedded_schema do
    field(:years, {:array, :integer})
    field(:vb1, {:array, :integer})
    field(:vb2, {:array, :integer})
    field(:categories, {:array, :integer})
  end

  def new(query \\ @default_values),
    do: %@me{} |> do_cast(query)

  def default() do
    new()
    |> do_cast(%{})
    |> map_vbs()
    |> apply_action!(:insert)
  end

  def validate(params \\ %{}) do
    new(%{})
    |> do_cast(params)
    |> map_vbs()
    |> apply_action(:insert)
  end

  defp do_cast(form, params), do: form |> cast(params, [:years, :vb1, :vb2, :categories])

  defp map_vbs(changeset) do
    changeset
    |> map_vbs(:vb1)
    |> map_vbs(:vb2)
  end

  defp map_vbs(changeset, key) do
    mapped_vbs = get_field(changeset, key) |> map()
    put_change(changeset, key, mapped_vbs)
  end

  defp map(nil), do: nil

  defp map(vbs), do: for(vb <- vbs, do: map_cat(vb)) |> to_flat_list()

  defp to_flat_list(vbs), do: vbs |> List.flatten() |> Enum.map(&Enum.to_list/1) |> List.flatten()
end
