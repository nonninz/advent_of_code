defmodule Instruction do
  defstruct op: nil, args: [], destination: nil, next: nil

  def decode(data, index) do
    instruction = :array.get(index, data)
    {op, args, destination} = op(instruction)

    struct(__MODULE__,
      op: op,
      args: fetch_args(args, instruction, index, data),
      destination: fetch_destination(destination, index, data),
      next: next_instruction(index, args, destination)
    )
  end

  defp op(code) when rem(code, 100) == 1, do: {:plus, [1, 2], 3}
  defp op(code) when rem(code, 100) == 2, do: {:multiply, [1, 2], 3}
  defp op(code) when rem(code, 100) == 3, do: {:input, [], 1}
  defp op(code) when rem(code, 100) == 4, do: {:output, [1], nil}
  defp op(code) when rem(code, 100) == 99, do: {:halt, [], nil}

  defp fetch_args(args, instruction, index, data) do
    args
    |> Enum.with_index(2)
    |> Enum.map(&fetch_arg(&1, instruction, index, data))
  end

  defp fetch_arg({arg, position}, instruction, index, data) do
    mode = get_mode(position, instruction)

    case mode do
      0 ->
        index + arg
        |> :array.get(data)
        |> :array.get(data)

      1 ->
        index + arg
        |> :array.get(data)
    end
  end

  defp get_mode(position, instruction) do
    power = 10 |> :math.pow(position) |> floor()
    instruction |> div(power) |> rem(10)
  end

  defp fetch_destination(nil, _, _), do: nil
  defp fetch_destination(destination, index, data) do
    :array.get(destination + index, data)
  end

  defp next_instruction(index, args, destination) do
    index + length(args) + if destination do 2 else 1 end
  end
end

defmodule Program do
  def run(data) do
    process(data, 0)
  end

  defp process(data, index) when index < elem(data, 1) do
    instruction = Instruction.decode(data, index)

    case instruction.op do
      :plus ->
          [arg1, arg2] = instruction.args

          instruction.destination
          |> :array.set(arg1 + arg2, data)
          |> process(instruction.next)

      :multiply ->
          [arg1, arg2] = instruction.args

          instruction.destination
          |> :array.set(arg1 * arg2, data)
          |> process(instruction.next)

      :input ->
          {arg, _} = Integer.parse(IO.read(:line))

          instruction.destination
          |> :array.set(arg, data)
          |> process(instruction.next)

      :output ->
          [arg] = instruction.args

          IO.puts("#{arg}")

          process(data, instruction.next)

      :halt ->
        :halt
    end
  end

  defp process(data, _), do: data
end

"input"
|> File.read!()
|> String.trim()
|> String.split(",")
|> Enum.map(&String.to_integer/1)
|> :array.from_list()
|> Program.run()
