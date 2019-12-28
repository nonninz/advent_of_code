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
  defp op(code) when rem(code, 100) == 5, do: {:jump_if_true, [1, 2], nil}
  defp op(code) when rem(code, 100) == 6, do: {:jump_if_false, [1, 2], nil}
  defp op(code) when rem(code, 100) == 7, do: {:less_than, [1, 2], 3}
  defp op(code) when rem(code, 100) == 8, do: {:equals, [1, 2], 3}
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
  defstruct data: nil, inputs: [], outputs: [], ip: 0

  def run(data, inputs) do
    process(data, inputs, 0)
  end

  defp process(data, inputs, index) when index < elem(data, 1) do
    instruction = Instruction.decode(data, index)

    case instruction.op do
      :plus ->
          [arg1, arg2] = instruction.args

          instruction.destination
          |> :array.set(arg1 + arg2, data)
          |> process(inputs, instruction.next)

      :multiply ->
          [arg1, arg2] = instruction.args

          instruction.destination
          |> :array.set(arg1 * arg2, data)
          |> process(inputs, instruction.next)

      :input ->
          [arg | inputs] = inputs

          instruction.destination
          |> :array.set(arg, data)
          |> process(inputs, instruction.next)

      :output ->
          [arg] = instruction.args

          process(data, inputs, instruction.next) ++ arg

      :jump_if_true ->
          [arg, destination] = instruction.args

          if arg != 0 do
            process(data, inputs, destination)
          else
            process(data, inputs, instruction.next)
          end

      :jump_if_false ->
          [arg, destination] = instruction.args

          if arg == 0 do
            process(data, inputs, destination)
          else
            process(data, inputs, instruction.next)
          end

      :less_than ->
          result = if apply(&Kernel.</2, instruction.args), do: 1, else: 0

          instruction.destination
          |> :array.set(result, data)
          |> process(inputs, instruction.next)

      :equals ->
          result = if apply(&Kernel.==/2, instruction.args), do: 1, else: 0

          instruction.destination
          |> :array.set(result, data)
          |> process(inputs, instruction.next)

      :halt ->
        []
    end
  end

  defp process(_data, _inputs, _), do: []
end

defmodule Stages do
  def brute_force(program) do
    [0,1,2,3,4]
    |> permute()
    |> Enum.map(&init(program, &1))
    |> Enum.max()
  end

  def init(program, phases) do
    phases
    |> Enum.reduce(0, fn phase, input ->
        Program.run(program, [phase, input])
    end)
  end

  def permute([]), do: [[]]
  def permute(list) do
    for x <- list, y <- permute(list -- [x]), do: [x|y]
  end
end


"input"
|> File.read!()
|> String.trim()
|> String.split(",")
|> Enum.map(&String.to_integer/1)
|> :array.from_list()
|> Stages.brute_force()
|> IO.inspect()
