defmodule Day24.BugLyfe do
  @doc """
      iex> Day24.BugLyfe.part1("day24-sample.txt")
      2129920
      iex> Day24.BugLyfe.part1("day24.txt")
      32526865
  """
  def part1(filename) do
    parse_input(filename)
    |> iterate(%{})
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

  def to_base10_int(list), do: Integer.undigits(Enum.reverse(list), 2)

  # def to_base2_list(base10int), do: Integer.digits(base10int, 2)

  def iterate(state, history) do
    draw(state)
    new_state = evolve(state)

    new_state_base10_int = to_base10_int(new_state)

    if history[new_state_base10_int] do
      IO.puts("Repeat found:")
      draw(new_state)
      new_state_base10_int
    else
      iterate(new_state, Map.put(history, new_state_base10_int, true))
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
  end

  def evolve(state, new_state \\ [], index \\ 0)
  def evolve(state, new_state, index) when index >= length(state), do: Enum.reverse(new_state)

  def evolve(state, new_state, index) do
    tile = Enum.at(state, index)
    neighbor_count = neighbors(state, index) |> Enum.count(&(&1 == 1))

    new_tile =
      cond do
        tile == 1 and neighbor_count != 1 -> 0
        tile == 0 and (neighbor_count == 1 or neighbor_count == 2) -> 1
        true -> tile
      end

    evolve(state, [new_tile | new_state], index + 1)
  end

  def neighbors(state, index, size \\ 5) do
    col = rem(index, size)
    row = div(index, size)

    [
      n_neighbor(col, row, size - 1),
      s_neighbor(col, row, size - 1),
      e_neighbor(col, row, size - 1),
      w_neighbor(col, row, size - 1)
    ]
    |> Enum.filter(& &1)
    |> Enum.map(fn point -> at_loc(state, size, point) end)
  end

  def n_neighbor(_col, 0, _max), do: nil
  def n_neighbor(col, row, _max), do: {col, row - 1}
  def s_neighbor(_col, max, max), do: nil
  def s_neighbor(col, row, _max), do: {col, row + 1}
  def w_neighbor(0, _row, _max), do: nil
  def w_neighbor(col, row, _max), do: {col - 1, row}
  def e_neighbor(max, _row, max), do: nil
  def e_neighbor(col, row, _max), do: {col + 1, row}

  def at_loc(state, size, {col, row}), do: Enum.at(state, row * size + col)
end
