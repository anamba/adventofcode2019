defmodule Day1.FuelCalculator do
  def run do
    File.stream!("inputs/day1.txt")
    |> Stream.map(&fuel_requirement_for_module_with_mass/1)
    |> Enum.reduce(0, fn acc, n -> acc + n end)
  end

  @doc ~S"""
    Fuel required to launch a given module is based on its mass. Specifically, to find the fuel required for a module:
    take its mass, divide by three, round down, and subtract 2.

      iex> Day1.FuelCalculator.fuel_requirement_for_module_with_mass("12")
      2
      iex> Day1.FuelCalculator.fuel_requirement_for_module_with_mass(14)
      2
      iex> Day1.FuelCalculator.fuel_requirement_for_module_with_mass("1969")
      654
      iex> Day1.FuelCalculator.fuel_requirement_for_module_with_mass(100756)
      33583
  """
  def fuel_requirement_for_module_with_mass(mass) when is_binary(mass) do
    mass
    |> String.trim()
    |> String.to_integer()
    |> fuel_requirement_for_module_with_mass()
  end

  def fuel_requirement_for_module_with_mass(mass) do
    div(mass, 3) - 2
  end
end
