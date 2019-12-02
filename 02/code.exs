defmodule Program do
  def find(data, expected) do
    possible_terms = for noun <- 0..99, verb <- 0..99, do: {noun, verb}

    brute_force(data, expected, possible_terms)
  end

  defp brute_force(data, expected, [{noun, verb} | rest]) do
    new_data = :array.set(1, noun, data)
    new_data = :array.set(2, verb, new_data)

    case process(new_data, 0) do
      ^expected ->
        100 * noun + verb

      _ ->
        brute_force(data, expected, rest)
    end
  end

  defp process(data, index) when index < elem(data, 1) do
    opcode = :array.get(index, data)
    destination = :array.get(index + 3, data)

    arg1 = get_param(index + 1, data)
    arg2 = get_param(index + 2, data)

    case op(opcode) do
      :plus ->
        destination
        |> :array.set(arg1 + arg2, data)
        |> process(index + 4)

      :multiply ->
        destination
        |> :array.set(arg1 * arg2, data)
        |> process(index + 4)

      :halt ->
        :array.get(0, data)
    end
  end

  defp process(data, _), do: data

  defp get_param(index, data ) do
    index
    |> :array.get(data)
    |> :array.get(data)
  end

  defp op(1), do: :plus
  defp op(2), do: :multiply
  defp op(99), do: :halt
end

result = "input"
        |> File.read!()
        |> String.trim()
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> :array.from_list()
        |> Program.find(19690720)

IO.puts("The result is #{result}")
