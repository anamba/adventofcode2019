defmodule Day19.TractorTester do
  @doc """
      iex> Day19.TractorTester.part1(50)
      138
  """
  def part1(dim \\ 50) do
    program = read_program()

    map =
      for y <- 0..(dim - 1), x <- 0..(dim - 1) do
        {nil, [output]} = start_program(program, [x, y])
        {x, y, output}
      end

    # display(map)

    map
    |> Enum.filter(fn {_, _, output} -> output == 1 end)
    |> Enum.count()
  end

  def read_program do
    "inputs/day19.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
  end

  def start_program(program, inputs) do
    Day11.IntcodeInterpreter.start_program(program, inputs, [])
  end

  def display(map) do
    clear_screen()

    map
    |> Enum.map(&paint/1)
  end

  def clear_screen, do: IO.write(IO.ANSI.clear())

  def paint({x, y, output}) do
    IO.write(IO.ANSI.cursor(y + 1, x + 1))
    IO.write(if output == 1, do: "#", else: ".")
  end

  @doc """
      iex> Day19.TractorTester.part2(100)
      13530764
  """
  def part2(dim \\ 100) do
    program = read_program()
    # clear_screen()

    {x, y} = iterate({0, 0}, dim, program, %{})
    x * 10000 + y
  end

  # start with NW corner at known good location (0,0)
  # move S until NE corner hits
  # move E until SW corner hits
  # ... continue until both SW and NE corners are set (done)
  def iterate({x, y} = loc, dim, program, history) do
    sw = {x, y + dim - 1}
    ne = {x + dim - 1, y}

    {0, dy, history} = move_into_beam(ne, 0, 1, program, history)
    {dx, 0, history} = move_into_beam(sw, 1, 0, program, history)

    new_loc = {x + dx, y + dy}

    if new_loc == loc do
      new_loc
    else
      iterate(new_loc, dim, program, history)
    end
  end

  def move_into_beam({x, y} = loc, dx, dy, program, history, xdist \\ 0, ydist \\ 0) do
    {result, history} = test_location(loc, program, history)

    if result == 1 do
      {xdist, ydist, history}
    else
      move_into_beam({x + dx, y + dy}, dx, dy, program, history, xdist + dx, ydist + dy)
    end
  end

  def test_location({x, y} = loc, program, history) do
    data = history[loc]

    if data do
      # we already tested this point
      {data, history}
    else
      {nil, [output]} = start_program(program, [x, y])
      # paint({x, y, output})
      {output, Map.put(history, loc, output)}
    end
  end
end
