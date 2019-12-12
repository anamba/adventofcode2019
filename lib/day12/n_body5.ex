# finally got it after a little hint from reddit
# https://www.reddit.com/r/adventofcode/comments/e9jxh2/help_2019_day_12_part_2_what_am_i_not_seeing/
#
# find the x cycle, y cycle, z cycle, then find the first time they all cycle together
defmodule Day12.NBody5 do
  def part2 do
    # puzzle input
    # positions = %{
    #   :a => {-1, 7, 3},
    #   :b => {12, 2, -13},
    #   :c => {14, 18, -8},
    #   :d => {17, 4, -4}
    # }
    xpositions = %{:a => -1, :b => 12, :c => 14, :d => 17}
    ypositions = %{:a => 7, :b => 2, :c => 18, :d => 4}
    zpositions = %{:a => 3, :b => -13, :c => -8, :d => -4}

    # example 1
    # positions = %{
    #   :a => {-1, 0, 2},
    #   :b => {2, -10, -7},
    #   :c => {4, -8, 8},
    #   :d => {3, 5, -1}
    # }
    # xpositions = %{:a => -1, :b => 2, :c => 4, :d => 3}
    # ypositions = %{:a => 0, :b => -10, :c => -8, :d => 5}
    # zpositions = %{:a => 2, :b => -7, :c => 8, :d => -1}

    # example 2
    # positions = %{
    #   :a => {-8, -10, 0},
    #   :b => {5, 5, 10},
    #   :c => {2, -7, 3},
    #   :d => {9, -8, -3}
    # }

    all_pairs = create_pairs(Map.keys(xpositions))
    velocities = %{:a => 0, :b => 0, :c => 0, :d => 0}

    x =
      iterate(all_pairs, xpositions, xpositions, velocities)
      |> IO.inspect(label: "X repeat found at iteration")

    y =
      iterate(all_pairs, ypositions, ypositions, velocities)
      |> IO.inspect(label: "Y repeat found at iteration")

    z =
      iterate(all_pairs, zpositions, zpositions, velocities)
      |> IO.inspect(label: "Z repeat found at iteration")

    gcd = [Integer.gcd(x, y), Integer.gcd(y, z), Integer.gcd(x, z)] |> Enum.min()

    div(x, gcd) * div(y, gcd) * div(z, gcd)
  end

  def iterate(pairs, target_positions, positions, velocities, iteration \\ 1) do
    new_velocities = apply_gravity(pairs, positions, velocities)
    new_positions = apply_velocities(positions, new_velocities)

    if new_positions == target_positions && Map.values(new_velocities) == [0, 0, 0, 0] do
      iteration
    else
      # if rem(iteration, 100_000) == 0 do
      #   IO.puts("Iteration #{iteration}")
      #   IO.inspect({new_positions, new_velocities})
      # end

      iterate(pairs, target_positions, new_positions, new_velocities, iteration + 1)
    end
  end

  @doc """
      iex> Day12.NBody5.create_pairs ["a", "b"]
      [{"a", "b"}]
      iex> Day12.NBody5.create_pairs ["a", "b", "c"]
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
    {va, vb} = new_velocities({positions[a], positions[b]}, {velocities[a], velocities[b]})

    velocities =
      velocities
      |> Map.put(a, va)
      |> Map.put(b, vb)

    apply_gravity(pairs, positions, velocities)
  end

  def new_velocities({a, b}, {av, bv}) do
    {av + dv(a, b), bv + dv(b, a)}
  end

  def dv(a, b) when a > b, do: -1
  def dv(a, b) when a == b, do: 0
  def dv(a, b) when a < b, do: 1

  def apply_velocities(positions, velocities) do
    positions
    |> Enum.map(fn {key, pos} -> {key, apply_velocity(pos, velocities[key])} end)
    |> Enum.into(%{})
  end

  def apply_velocity(x, vx), do: x + vx
end
