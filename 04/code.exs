defmodule Password do
  def convert(pass) do
    Integer.to_charlist(pass)
  end

  def has_double_digits?(number) do
    number
    |> Enum.chunk_by(& &1)
    |> Enum.any?(&length(&1) == 2)
  end

  def has_ascending_digits?([first, second | rest]) do
    if first > second do
      false
    else
      has_ascending_digits?([second | rest])
    end
  end

  def has_ascending_digits?(_), do: true
end

372304..847060
|> Enum.map(&Password.convert/1)
|> Enum.filter(&Password.has_ascending_digits?/1)
|> Enum.filter(&Password.has_double_digits?/1)
|> length()
|> IO.inspect
