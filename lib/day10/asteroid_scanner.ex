defmodule Day10.AsteroidScanner do
  @doc """
      iex> Day10.AsteroidScanner.part1("day10-sample0.txt")
      "Best is 3,4 with 8 other asteroids detected"
      iex> Day10.AsteroidScanner.part1("day10-sample1.txt")
      "Best is 5,8 with 33 other asteroids detected"
      iex> Day10.AsteroidScanner.part1("day10-sample2.txt")
      "Best is 1,2 with 35 other asteroids detected"
      iex> Day10.AsteroidScanner.part1("day10-sample3.txt")
      "Best is 6,3 with 41 other asteroids detected"
      iex> Day10.AsteroidScanner.part1("day10-sample4.txt")
      "Best is 11,13 with 210 other asteroids detected"
  """
  def part1(filename \\ "day10.txt") do
    lines =
      "inputs/#{filename}"
      |> File.stream!()
      |> Enum.map(fn line -> line |> String.trim() |> String.graphemes() end)

    xmin = 0
    ymin = 0
    xmax = length(List.first(lines)) - 1
    ymax = length(lines) - 1

    bounds = [xmin, ymin, xmax, ymax]

    # parse input into list of coordinates
    asteroid_list = to_asteroid_list(lines)
    asteroid_map = to_asteroid_map(asteroid_list)

    {n, {x, y}} =
      asteroid_list
      |> Enum.map(&evaluate_location(&1, asteroid_list, asteroid_map, bounds))
      |> Enum.sort()
      |> List.last()

    "Best is #{x},#{y} with #{n} other asteroids detected"
  end

  def to_asteroid_list(lines) do
    lines
    |> Enum.with_index()
    |> Enum.map(fn {line, y} ->
      line
      |> Enum.with_index()
      |> Enum.map(fn {char, x} ->
        case char do
          "#" -> {x, y}
          _ -> nil
        end
      end)
    end)
    |> List.flatten()
    |> Enum.filter(& &1)
  end

  def to_asteroid_map([]), do: %{}

  def to_asteroid_map([asteroid | list]),
    do: Enum.into(%{asteroid => true}, to_asteroid_map(list))

  @doc """
      iex> Day10.AsteroidScanner.evaluate_location({1, 2}, [{1, 0}, {4, 0}, {0, 2}, {1, 2}, {2, 2}, {3, 2}, {4, 2}, {4, 3}, {3, 4}, {4, 4}], %{{0, 2} => true, {1, 0} => true, {1, 2} => true, {2, 2} => true, {3, 2} => true, {3, 4} => true, {4, 0} => true, {4, 2} => true, {4, 3} => true, {4, 4} => true}, [0,0, 4,4])
      {7, {1, 2}}
      iex> Day10.AsteroidScanner.evaluate_location({3, 4}, [{1, 0}, {4, 0}, {0, 2}, {1, 2}, {2, 2}, {3, 2}, {4, 2}, {4, 3}, {3, 4}, {4, 4}], %{{0, 2} => true, {1, 0} => true, {1, 2} => true, {2, 2} => true, {3, 2} => true, {3, 4} => true, {4, 0} => true, {4, 2} => true, {4, 3} => true, {4, 4} => true}, [0,0, 4,4])
      {8, {3, 4}}
  """
  def evaluate_location({x, y}, asteroid_list, asteroid_map, bounds) do
    visible_count =
      asteroid_list
      |> Stream.reject(&(&1 == {x, y}))
      |> Stream.map(&clear_line_of_sight?({x, y}, &1, asteroid_map, bounds))
      |> Enum.count(& &1)

    {visible_count, {x, y}}
  end

  # if we have reached the destination, return true
  def clear_line_of_sight?(n, n, _asteroid_map, _bounds), do: true

  # if we are outside bounds, return false
  def clear_line_of_sight?({x1, y1}, _dest, _asteroid_map, [xmin, ymin, xmax, ymax])
      when x1 < xmin or x1 > xmax or y1 < ymin or y1 > ymax,
      do: false

  def clear_line_of_sight?({x1, y1}, dest = {x2, y2}, asteroid_map, bounds) do
    # calculate slope
    {rise, run} = {y2 - y1, x2 - x1} |> to_fraction()

    # move one step toward <dest>
    new_pos = {x1 + run, y1 + rise}

    cond do
      # if we are at dest, return true
      new_pos == dest -> true
      # if we hit something else, return false
      asteroid_map[new_pos] -> false
      # otherwise, continue on
      true -> clear_line_of_sight?(new_pos, dest, asteroid_map, bounds)
    end
  end

  def to_fraction({a, b}) do
    gcd = Integer.gcd(a, b)
    {div(a, gcd), div(b, gcd)}
  end
end
