defmodule Day10.AsteroidVaporizer do
  @doc """
      iex> Day10.AsteroidVaporizer.part2("day10-sample4.txt", {11,13})
      true
  """
  def part2(filename \\ "day10.txt", laser_position \\ {14, 17}) do
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

    iterate(laser_position, asteroid_list, asteroid_map, bounds)
  end

  def iterate(laser_position, asteroid_list, asteroid_map, bounds, counter \\ 0) do
    asteroids =
      visible_asteroids(laser_position, asteroid_list, asteroid_map, bounds)
      |> sort_by_angle(laser_position)

    if length(asteroids) == 0 do
      true
    else
      {_, new_counter} =
        asteroids
        |> Enum.with_index(counter + 1)
        |> Enum.map(fn {asteroid, n} -> {destroy_asteroid(asteroid, n), n} end)
        |> List.last()

      asteroid_list = asteroid_list -- asteroids
      asteroid_map = Map.drop(asteroid_map, asteroids)

      cond do
        new_counter == counter -> true
        new_counter > 300 -> true
        true -> iterate(laser_position, asteroid_list, asteroid_map, bounds, new_counter)
      end
    end
  end

  def sort_by_angle(asteroids, {x1, y1}) do
    asteroids
    |> Stream.map(fn {x2, y2} -> {{x2, y2}, :math.atan2(y2 - y1, x2 - x1)} end)
    |> Enum.sort_by(fn {_, angle} -> {angle < -:math.pi() / 2, angle} end)
    |> Enum.map(fn {pos, _} -> pos end)
  end

  def destroy_asteroid({x, y}, n) do
    case n do
      1 ->
        IO.puts("The 1st asteroid to be vaporized is at #{x},#{y}.")

      2 ->
        IO.puts("The 2nd asteroid to be vaporized is at #{x},#{y}.")

      3 ->
        IO.puts("The 3rd asteroid to be vaporized is at #{x},#{y}.")

      201 ->
        IO.puts("The 201st asteroid to be vaporized is at #{x},#{y}.")

      n when n in [10, 20, 50, 100, 199, 200, 201, 299] ->
        IO.puts("The #{n}th asteroid to be vaporized is at #{x},#{y}.")

      _ ->
        nil
    end
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

  def visible_asteroids({x, y}, asteroid_list, asteroid_map, bounds) do
    asteroid_list
    |> Stream.reject(&(&1 == {x, y}))
    |> Stream.map(fn asteroid ->
      {asteroid, clear_line_of_sight?({x, y}, asteroid, asteroid_map, bounds)}
    end)
    |> Stream.filter(fn {_, visible} -> visible end)
    |> Enum.map(fn {asteroid, _} -> asteroid end)
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
