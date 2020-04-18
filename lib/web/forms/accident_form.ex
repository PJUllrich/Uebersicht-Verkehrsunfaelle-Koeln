defmodule Web.AccidentForm do
  use Web, :form_object

  @default_values %{years: [2017], vb1: [1], vb2: [3], categories: [1, 2, 3]}

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
    new()
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
    vbs = get_field(changeset, key)
    mapped_vbs = map(vbs)
    put_change(changeset, key, mapped_vbs)
  end

  defp map(nil), do: nil

  defp map(vbs), do: for(vb <- vbs, do: map_vb(vb)) |> to_flat_list()

  # Maps "Keiner/Alleinunfall" to placeholder for empty vb2 values, which is 0
  defp map_vb(0), do: [0..0]

  # Maps "KFZ" to the numerical police categories for "Motorized Bike" (1 to 19), "Car" (20 to 29) and "Truck" (40 to 59)
  defp map_vb(1), do: [1..19, 20..29]

  # Maps "LKW" to the numerical police categories "Truck" (40 to 59)
  defp map_vb(2), do: [40..59]

  # Maps "Rad" to the numerical police categories for "Bicycle" (70 to 79)
  defp map_vb(3), do: [70..79]

  # Maps "Fuß" to the numerical police categories for "Pedestrian" (80 to 89 and 93)
  defp map_vb(4), do: [80..89, 93..93]

  # Maps "Bus and Bahn" to the numerical police categories for "(public) Bus" (30 to 39) and "Train" (60 to 69)
  defp map_vb(5), do: [30..39, 60..69]

  defp to_flat_list(vbs), do: vbs |> List.flatten() |> Enum.map(&Enum.to_list/1) |> List.flatten()
end
