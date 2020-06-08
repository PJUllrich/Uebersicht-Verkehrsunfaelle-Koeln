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

  # Maps "Keiner/Alleinunfall" to placeholder for empty vb2 values, which is 0
  def map_cat(0), do: [0..0]

  # Maps "KFZ" to the numerical police categories for "Motorized Bike" (1 to 19), "Car" (20 to 29) and "Truck" (40 to 59)
  def map_cat(1), do: [1..19, 20..29]

  # Maps "LKW" to the numerical police categories "Truck" (40 to 59)
  def map_cat(2), do: [40..59]

  # Maps "Rad" to the numerical police categories for "Bicycle" (70 to 79)
  def map_cat(3), do: [70..79]

  # Maps "Fuß" to the numerical police categories for "Pedestrian" (80 to 89 and 93)
  def map_cat(4), do: [80..89, 93..93]

  # Maps "Bus and Bahn" to the numerical police categories for "(public) Bus" (30 to 39) and "Train" (60 to 69)
  def map_cat(5), do: [30..39, 60..69]

  # Maps placeholder 0 to "Keiner/Alleinunfall" category
  def map_to_cat(vb) when is_nil(vb) or vb in 0..0, do: 0

  # Maps values to "KFZ/Krad" category
  def map_to_cat(vb) when vb in 1..29, do: 1

  # Maps values to "LKW" category
  def map_to_cat(vb) when vb in 40..59, do: 2

  # Maps values to "Rad" category
  def map_to_cat(vb) when vb in 70..79, do: 3

  # Maps values to "Fuß" category
  def map_to_cat(vb) when vb in 80..89, do: 4
  def map_to_cat(vb) when vb in 93..93, do: 4

  # Maps values to "Bus und Bahn" category
  def map_to_cat(vb) when vb in 30..39, do: 5
  def map_to_cat(vb) when vb in 60..69, do: 5
end
