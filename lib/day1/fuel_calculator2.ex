defmodule Day1.FuelCalculator2 do
  def run do
    File.stream!("inputs/day1.txt")
    |> Stream.map(&fuel_requirement_for_module_with_mass/1)
    |> Enum.reduce(0, fn acc, n -> acc + n end)
  end

  @doc ~S"""
    Fuel required to launch a given module is based on its mass. Specifically, to find the fuel required for a module:
    take its mass, divide by three, round down, and subtract 2.

      iex> Day1.FuelCalculator2.fuel_requirement_for_module_with_mass("0")
      0
      iex> Day1.FuelCalculator2.fuel_requirement_for_module_with_mass("12")
      2
      iex> Day1.FuelCalculator2.fuel_requirement_for_module_with_mass(14)
      2
      iex> Day1.FuelCalculator2.fuel_requirement_for_module_with_mass("1969")
      966
      iex> Day1.FuelCalculator2.fuel_requirement_for_module_with_mass(100756)
      50346
  """
  def fuel_requirement_for_module_with_mass(mass) when is_binary(mass) do
    mass
    |> String.trim()
    |> String.to_integer()
    |> fuel_requirement_for_module_with_mass()
  end

  def fuel_requirement_for_module_with_mass(mass) do
    fuelreq = div(mass, 3) - 2

    cond do
      fuelreq <= 0 -> 0
      true -> fuelreq + fuel_requirement_for_module_with_mass(fuelreq)
    end
  end
end
