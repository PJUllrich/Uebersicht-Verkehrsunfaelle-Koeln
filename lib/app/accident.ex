defmodule App.Accident do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accidents" do
    field(:latitude, :float)
    field(:longitude, :float)
    field(:vb1, :integer)
    field(:vb2, :integer)
    field(:year, :integer)

    timestamps()
  end

  @doc false
  def changeset(accident, attrs) do
    accident
    |> cast(attrs, [:year, :latitude, :longitude, :vb1, :vb2])
    |> validate_required([:year, :latitude, :longitude])
    |> validate_required_inclusion([:vb1, :vb2])
  end

  defp validate_required_inclusion(changeset, fields, _options \\ []) do
    if Enum.any?(fields, fn field -> get_field(changeset, field) end),
      do: changeset,
      else:
        add_error(
          changeset,
          hd(fields),
          "One of these fields must be present: #{inspect(fields)}"
        )
  end
end
