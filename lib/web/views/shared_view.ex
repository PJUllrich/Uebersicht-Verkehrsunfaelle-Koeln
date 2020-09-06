defmodule Web.SharedView do
  def years() do
    [
      %{value: 2020, text: "2020 1. HJ"},
      %{value: 2019, text: "2019"},
      %{value: 2018, text: "2018"},
      %{value: 2017, text: "2017"},
      %{value: 2016, text: "2016"},
      %{value: 2015, text: "2015"},
      %{value: 2014, text: "2014"},
      %{value: 2013, text: "2013"}
    ]
  end

  def vb1() do
    [
      %{value: 1, text: "PKW/Krad"},
      %{value: 2, text: "LKW"},
      %{value: 3, text: "Rad"},
      %{value: 4, text: "Fuß"},
      %{value: 5, text: "Bus & Bahn"}
    ]
  end

  def vb2() do
    [
      %{value: 1, text: "PKW/Krad"},
      %{value: 2, text: "LKW"},
      %{value: 3, text: "Rad"},
      %{value: 4, text: "Fuß"},
      %{value: 5, text: "Bus & Bahn"},
      %{value: 0, text: "Keiner/Alleinunfall"}
    ]
  end

  def categories() do
    [
      %{value: 1, text: "Tödlich"},
      %{value: 2, text: "Schwerverletzt"},
      %{value: 3, text: "Leichtverletzt"}
    ]
  end
end
