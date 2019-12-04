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

  def manhattan_distance(left, right) when length(left) >= length(right) do
    left
    |> Enum.filter(fn point -> point in right end)
    |> Enum.map(fn point -> abs(point.x) + abs(point.y) end)
    |> Enum.min
  end

  def manhattan_distance(left, right), do: manhattan_distance(right, left)
end

calc_distance = fn [left, right] ->
  Wire.manhattan_distance(left, right)
end

"input"
|> File.stream!()
|> Stream.map(&String.trim/1)
|> Stream.map(&String.split(&1, ","))
|> Enum.map(&Wire.build/1)
|> calc_distance.()
|> IO.puts()
