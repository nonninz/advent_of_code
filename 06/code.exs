defmodule Orbit do
  #defstruct name: nil, parent: nil, descendants: []

  def new(), do: %{}

  def add(orbit, entry) do
    [parent, planet] = String.split(entry, ")")

    Map.put(orbit, planet, parent)
  end

  def total(orbit) do
    orbit
    |> Map.keys()
    |> Enum.map(&count(orbit, &1))
    |> Enum.sum()
  end

  defp count(_orbits, "COM"), do: 0

  defp count(orbits, planet) do
    1 + count(orbits, orbits[planet])
  end
end

"input"
|> File.read!()
|> String.trim()
|> String.split("\n")
|> Enum.reduce(Orbit.new(), &Orbit.add(&2, &1))
#> IO.inspect(label: "orbits")
|> Orbit.total()
|> IO.inspect()
