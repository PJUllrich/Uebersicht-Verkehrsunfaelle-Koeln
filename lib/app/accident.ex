defmodule App.Accident do
  use Ecto.Schema

  schema "accidents" do
    field(:latitude, :float)
    field(:longitude, :float)
    field(:vb1, :integer)
    field(:vb2, :integer)
    field(:year, :integer)
    field(:category, :integer)
  end
end
