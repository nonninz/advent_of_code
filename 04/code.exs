defmodule Password do
  def convert(pass) do
    Integer.to_charlist(pass)
  end

  def has_double_digits?([first, second | rest]) do
    if first == second do
      true
    else
      has_double_digits?([second | rest])
    end
  end

  def has_double_digits?(_), do: false

  def has_ascending_digits?([first, second | rest]) do
    unless first <= second do
      false
    else
      has_ascending_digits?([second | rest])
    end
  end

  def has_ascending_digits?(u), do: IO.inspect(u)
end

372304..847060
|> Enum.map(&Password.convert/1)
|> Enum.filter(&Password.has_double_digits?/1)
|> Enum.filter(&Password.has_ascending_digits?/1)
|> length()
|> IO.inspect
