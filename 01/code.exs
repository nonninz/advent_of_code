defmodule FuelConsumption do
  require Logger

  def for_module(mass) do
    fuel = calculate(mass)

    Logger.info("Total fuel for mass #{mass}: #{fuel}")

    fuel
  end

  defp calculate(mass) when mass <= 0, do: 0
  defp calculate(mass) do
    fuel = positive_or_zero(floor(mass / 3) - 2)

    Logger.debug("Calculated fuel for mass #{mass}: #{fuel}")

    fuel + calculate(fuel)
  end

  defp positive_or_zero(number) when number > 0, do: number
  defp positive_or_zero(_), do: 0
end

Logger.configure(level: :info)

File.stream!("input")
#File.stream!("examples")
|> Stream.map(fn line -> line |> Integer.parse() |> elem(0) end)
|> Stream.map(&FuelConsumption.for_module/1)
|> Enum.reduce(0, fn module, total -> module + total end)
|> IO.puts()
