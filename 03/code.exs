defmodule Wire do
  defstruct x: 0, y: 0

  def new(), do: [%__MODULE__{}]

  def build(points) do
    points
    |> Enum.reduce(new(), &plot/2)
    |> Enum.reverse()
    |> Enum.drop(1)
  end

  def plot(<<direction, value_bin :: binary>>, wire) do
    value = String.to_integer(value_bin)

    Enum.reduce(1..value, wire, fn _i, wire -> add(wire, direction) end)
  end

  def add([point | _] = wire, direction) do
    case direction do
      ?L ->
        [%{point | x: point.x - 1} | wire]
      ?R ->
        [%{point | x: point.x + 1} | wire]
      ?U ->
        [%{point | y: point.y + 1} | wire]
      ?D ->
        [%{point | y: point.y - 1} | wire]
    end
  end
end

defmodule Panel do
  def new, do: %{}

  def add(panel, {points, index}) do
    points
    |> Enum.with_index(1)
    |> Enum.reduce(panel, fn {point, distance}, panel ->
      add_point(panel, point, index, distance)
    end)
    |> Map.update(:wires, index, &max(&1, index))
  end

  defp add_point(panel, point, wire_index, distance) do
    case Map.get(panel, point) do
      nil ->
        Map.put(panel, point, %{wire_index => distance})

      %{^wire_index => prev_distance} when distance > prev_distance ->
        # Existing distance is lower already
        panel

      distances ->
        Map.put(panel, point, Map.put(distances, wire_index, distance))
    end
  end

  def intersections(%{wires: wires} = panel) do
    panel
    |> Enum.filter(fn
      {:wires, _} ->
        false

      {_, distances} ->
        length(Map.keys(distances)) == wires

      end)
    |> Enum.into(%{})
  end

  def manhattan_distances(panel) do
    panel
    |> intersections()
    |> Map.keys()
    |> Enum.map(fn point -> abs(point.x) + abs(point.y) end)
  end

  def total_intersection_distances(panel) do
    panel
    |> intersections()
    |> Enum.map(fn {_point, distances} ->
      distances |> Map.values() |> Enum.sum()
    end)
  end
end

"input"
|> File.stream!()
|> Stream.map(&String.trim/1)
|> Stream.map(&String.split(&1, ","))
|> Enum.map(&Wire.build/1)
|> Enum.with_index(1)
|> Enum.reduce(Panel.new(), &Panel.add(&2, &1))
#> Panel.manhattan_distances()
|> Panel.total_intersection_distances()
|> Enum.min()
|> IO.inspect()
