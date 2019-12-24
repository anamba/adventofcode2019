defmodule Day24.BugLyfe2 do
  @doc """
      iex> Day24.BugLyfe2.part2("day24-sample.txt", 10)
      99
      iex> Day24.BugLyfe2.part2("day24.txt", 200)
      2009
  """
  def part2(filename, time_limit) do
    level0 = parse_input(filename)

    iterate(%{0 => level0}, time_limit)
  end

  def parse_input(filename) do
    "inputs/#{filename}"
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Enum.map(&String.graphemes/1)
    |> List.flatten()
    |> Enum.map(fn c ->
      case c do
        "#" -> 1
        _ -> 0
      end
    end)
  end

  def iterate(state, time_limit, minute \\ 1) do
    new_state = evolve(state)

    bug_count =
      new_state
      |> Map.values()
      |> List.flatten()
      |> Enum.count(&(&1 == 1))

    if minute < time_limit do
      iterate(new_state, time_limit, minute + 1)
    else
      bug_count
    end
  end

  def draw(state, width \\ 5) do
    state
    |> Enum.map(fn
      0 -> "."
      1 -> "#"
    end)
    |> Enum.chunk_every(width)
    |> Enum.join("\n")
    |> IO.puts()

    IO.puts("")

    state
  end

  def evolve(state) do
    levels_to_check = Map.keys(state)
    {min, max} = Enum.min_max(levels_to_check)
    min = if Enum.any?(state[min], &(&1 == 1)), do: min - 1, else: min
    max = if Enum.any?(state[max], &(&1 == 1)), do: max + 1, else: max

    levels_to_check =
      [min, levels_to_check, max]
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.drop(1)

    evolve(state, %{}, [], 0, min, levels_to_check)
  end

  def evolve(state, new_state, buffer, index, level, levels_to_check)

  def evolve(_state, new_state, buffer, 25, level, []) do
    Map.put(new_state, level, Enum.reverse(buffer))
  end

  def evolve(state, new_state, buffer, 25, level, [next_level | levels]) do
    new_state = Map.put(new_state, level, Enum.reverse(buffer))
    evolve(state, new_state, [], 0, next_level, levels)
  end

  def evolve(state, new_state, buffer, 12, level, levels_to_check) do
    evolve(state, new_state, [0 | buffer], 13, level, levels_to_check)
  end

  def evolve(state, new_state, buffer, index, level, levels_to_check) do
    neighbor_count =
      neighbors(state, index, level)
      |> Enum.count(&(&1 == 1))

    tile =
      if state[level] do
        Enum.at(state[level], index)
      else
        0
      end

    new_tile =
      cond do
        tile == 1 and neighbor_count != 1 -> 0
        tile == 0 and (neighbor_count == 1 or neighbor_count == 2) -> 1
        true -> tile
      end

    evolve(state, new_state, [new_tile | buffer], index + 1, level, levels_to_check)
  end

  def neighbors(state, index, level, size \\ 5) do
    col = rem(index, size)
    row = div(index, size)

    [
      n_neighbor(col, row, level, size - 1),
      s_neighbor(col, row, level, size - 1),
      e_neighbor(col, row, level, size - 1),
      w_neighbor(col, row, level, size - 1)
    ]
    |> List.flatten()
    |> Enum.map(fn point -> at_loc(state, size, point) end)
  end

  # added one more special case each to include the recursive grids and
  # gave the edges neighbors in the level above
  def n_neighbor(_col, 0, depth, _max), do: [{2, 1, depth - 1}]

  def n_neighbor(2, 3, depth, max) do
    for col <- 0..max, do: {col, max, depth + 1}
  end

  def n_neighbor(col, row, depth, _max), do: [{col, row - 1, depth}]
  def s_neighbor(_col, max, depth, max), do: [{2, 3, depth - 1}]

  def s_neighbor(2, 1, depth, max) do
    for col <- 0..max, do: {col, 0, depth + 1}
  end

  def s_neighbor(col, row, depth, _max), do: [{col, row + 1, depth}]
  def w_neighbor(0, _row, depth, _max), do: [{1, 2, depth - 1}]

  def w_neighbor(3, 2, depth, max) do
    for row <- 0..max, do: {max, row, depth + 1}
  end

  def w_neighbor(col, row, depth, _max), do: [{col - 1, row, depth}]
  def e_neighbor(max, _row, depth, max), do: [{3, 2, depth - 1}]

  def e_neighbor(1, 2, depth, max) do
    for row <- 0..max, do: {0, row, depth + 1}
  end

  def e_neighbor(col, row, depth, _max), do: [{col + 1, row, depth}]

  def at_loc(state, size, {col, row, level}) do
    if state[level] do
      Enum.at(state[level], row * size + col)
    else
      0
    end
  end
end
