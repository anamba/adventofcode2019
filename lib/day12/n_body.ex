defmodule Day12.NBody do
  def part1 do
    # puzzle input
    positions = %{
      :a => {-1, 7, 3},
      :b => {12, 2, -13},
      :c => {14, 18, -8},
      :d => {17, 4, -4}
    }

    # example 1
    # positions = %{
    #   :a => {-1, 0, 2},
    #   :b => {2, -10, -7},
    #   :c => {4, -8, 8},
    #   :d => {3, 5, -1}
    # }

    # example 2
    # positions = %{
    #   :a => {-8, -10, 0},
    #   :b => {5, 5, 10},
    #   :c => {2, -7, 3},
    #   :d => {9, -8, -3}
    # }

    all_pairs = create_pairs(Map.keys(positions))
    iterate(all_pairs, positions, %{})
  end

  def iterate(pairs, positions, velocities, iteration \\ 1) do
    new_velocities = apply_gravity(pairs, positions, velocities)

    new_positions =
      apply_velocities(positions, new_velocities) |> IO.inspect(label: "iteration #{iteration}")

    Map.keys(positions)
    |> Enum.map(&calculate_energy(new_positions[&1], new_velocities[&1]))
    |> Enum.sum()
    |> IO.inspect(label: "total energy")

    if iteration < 1000 do
      iterate(pairs, new_positions, new_velocities, iteration + 1)
    else
      {new_velocities, new_positions}
    end
  end

  @doc """
      iex> Day12.NBody.create_pairs ["a", "b"]
      [{"a", "b"}]
      iex> Day12.NBody.create_pairs ["a", "b", "c"]
      [{"a", "b"}, {"a", "c"}, {"b", "c"}]
  """
  def create_pairs(keys) do
    for key1 <- keys, key2 <- keys, key1 != key2 do
      [key1, key2] |> Enum.sort() |> List.to_tuple()
    end
    |> Enum.uniq()
  end

  def apply_gravity([], _positions, velocities), do: velocities

  def apply_gravity([{a, b} | pairs], positions, velocities) do
    {va, vb} =
      new_velocities(
        {positions[a], positions[b]},
        {Map.get(velocities, a, {0, 0, 0}), Map.get(velocities, b, {0, 0, 0})}
      )

    velocities =
      velocities
      |> Map.put(a, va)
      |> Map.put(b, vb)

    apply_gravity(pairs, positions, velocities)
  end

  @doc """
      iex> Day12.NBody.new_velocities({{3,4,5}, {5,4,3}}, {{0,0,0}, {0,0,0}})
      {{1,0,-1}, {-1,0,1}}
  """
  def new_velocities({{ax, ay, az}, {bx, by, bz}}, {{avx, avy, avz}, {bvx, bvy, bvz}}) do
    {{avx + dv(ax, bx), avy + dv(ay, by), avz + dv(az, bz)},
     {bvx + dv(bx, ax), bvy + dv(by, ay), bvz + dv(bz, az)}}
  end

  def dv(a, b) when a > b, do: -1
  def dv(a, b) when a == b, do: 0
  def dv(a, b) when a < b, do: 1

  def apply_velocities(positions, velocities) do
    positions
    |> Enum.map(fn {key, pos} -> {key, apply_velocity(pos, velocities[key])} end)
    |> Enum.into(%{})
  end

  def apply_velocity({x, y, z}, {vx, vy, vz}), do: {x + vx, y + vy, z + vz}

  def calculate_energy({x, y, z}, {vx, vy, vz}),
    do: (abs(x) + abs(y) + abs(z)) * (abs(vx) + abs(vy) + abs(vz))
end
