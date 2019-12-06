defmodule Day6.OrbitCounter2 do
  def run do
    pairs =
      "inputs/day6.txt"
      |> File.stream!()
      |> Stream.map(&String.trim/1)
      |> Enum.map(&parse_line_into_pair/1)

    direct = list_direct_orbits(pairs)
    indirect = list_indirect_orbits(Map.keys(direct), direct, %{})

    find_distance(direct, indirect, "YOU", "SAN")
  end

  @doc """
      iex> Day6.OrbitCounter2.find_distance(%{"A" => "Z", "B" => "3"}, %{"A" => ["COM", "W", "X", "Y"], "B" => ["COM", "X", "1", "2"]}, "A", "B")
      6
  """
  def find_distance(direct, indirect, node1, node2) do
    path1 = indirect[node1] ++ [direct[node1]]
    path2 = indirect[node2] ++ [direct[node2]]
    common_path = path1 -- path1 -- path2
    length(path1) + length(path2) - 2 * length(common_path)
  end

  @doc """
      iex> Day6.OrbitCounter2.parse_line_into_pair("COM)B")
      ["COM", "B"]
  """
  def parse_line_into_pair(line), do: String.split(line, ")")

  @doc """
      iex> Day6.OrbitCounter2.list_direct_orbits([["COM", "B"]])
      %{"B" => "COM"}
      iex> Day6.OrbitCounter2.list_direct_orbits([["COM", "B"], ["B", "C"]])
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
      iex> Day6.OrbitCounter2.list_indirect_orbits(["COM", "B"], %{"B" => "COM"}, %{})
      %{"B" => [], "COM" => []}
      iex> Day6.OrbitCounter2.list_indirect_orbits(["COM", "B", "C"], %{"B" => "COM", "C" => "B"}, %{})
      %{"B" => [], "C" => ["COM"], "COM" => []}
  """
  def list_indirect_orbits([], _, indirect), do: indirect

  def list_indirect_orbits([primary | primaries], direct, indirect) do
    ancestor = direct[primary]
    indirect = Map.put(indirect, primary, indirect_orbits(ancestor, direct))
    list_indirect_orbits(primaries, direct, indirect)
  end

  @doc """
      iex> Day6.OrbitCounter2.indirect_orbits("B", %{"C" => "B", "B" => "COM"})
      ["COM"]
      iex> Day6.OrbitCounter2.indirect_orbits("C", %{"D" => "C", "C" => "B", "B" => "COM"})
      ["COM", "B"]
  """
  def indirect_orbits(satellite, direct, ancestors \\ [])
  def indirect_orbits(nil, _, ancestors), do: ancestors

  def indirect_orbits(satellite, direct, ancestors) do
    ancestor = direct[satellite]
    if ancestor, do: indirect_orbits(ancestor, direct, [ancestor | ancestors]), else: ancestors
  end

  @doc """
      iex> Day6.OrbitCounter2.count_orbits({%{"B" => "COM", "C" => "B"}, %{"B" => [], "C" => ["COM"]}})
      3
  """
  def count_orbits({direct, indirect}) do
    length(Map.keys(direct)) + Enum.reduce(indirect, 0, fn {_, v}, acc -> acc + length(v) end)
  end
end
