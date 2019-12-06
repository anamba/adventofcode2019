defmodule Day6.OrbitCounter do
  def run do
    pairs =
      "inputs/day6.txt"
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Enum.map(&parse_line_into_pair/1)

    direct = list_direct_orbits(pairs)

    list_indirect_orbits(Map.keys(direct), direct, %{})
    |> count_orbits
  end

  @doc """
      iex> Day6.OrbitCounter.parse_line_into_pair("COM)B")
      ["COM", "B"]
  """
  def parse_line_into_pair(line), do: String.split(line, ")")

  @doc """
      iex> Day6.OrbitCounter.list_direct_orbits([["COM", "B"]])
      %{"B" => "COM"}
      iex> Day6.OrbitCounter.list_direct_orbits([["COM", "B"], ["B", "C"]])
      %{"B" => "COM", "C" => "B"}
  """
  def list_direct_orbits(pairs, direct \\ %{})
  def list_direct_orbits([], direct), do: direct

  def list_direct_orbits([pair | pairs], direct) do
    [primary, satellite] = pair
    direct = Map.put(direct, satellite, primary)
    list_direct_orbits(pairs, direct)
  end

  @doc """
      iex> Day6.OrbitCounter.list_indirect_orbits(["COM", "B"], %{"B" => "COM"}, %{})
      {%{"B" => "COM"}, %{"B" => [], "COM" => []}}
      iex> Day6.OrbitCounter.list_indirect_orbits(["COM", "B", "C"], %{"B" => "COM", "C" => "B"}, %{})
      {%{"B" => "COM", "C" => "B"}, %{"B" => [], "C" => ["COM"], "COM" => []}}
  """
  def list_indirect_orbits([], direct, indirect), do: {direct, indirect}

  def list_indirect_orbits([primary | primaries], direct, indirect) do
    ancestor = direct[primary]
    indirect = Map.put(indirect, primary, indirect_orbits(ancestor, direct))
    list_indirect_orbits(primaries, direct, indirect)
  end

  @doc """
      iex> Day6.OrbitCounter.indirect_orbits("B", %{"C" => "B", "B" => "COM"})
      ["COM"]
      iex> Day6.OrbitCounter.indirect_orbits("C", %{"D" => "C", "C" => "B", "B" => "COM"})
      ["COM", "B"]
  """
  def indirect_orbits(satellite, direct, ancestors \\ [])
  def indirect_orbits(nil, _, ancestors), do: ancestors

  def indirect_orbits(satellite, direct, ancestors) do
    ancestor = direct[satellite]
    if ancestor, do: indirect_orbits(ancestor, direct, [ancestor | ancestors]), else: ancestors
  end

  @doc """
      iex> Day6.OrbitCounter.count_orbits({%{"B" => "COM", "C" => "B"}, %{"B" => [], "C" => ["COM"]}})
      3
  """
  def count_orbits({direct, indirect}) do
    length(Map.keys(direct)) + Enum.reduce(indirect, 0, fn {_, v}, acc -> acc + length(v) end)
  end
end
