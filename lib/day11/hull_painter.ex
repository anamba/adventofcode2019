defmodule Day11.HullPainter do
  def part1 do
    pid = read_program() |> start_program

    iterate(pid)
    |> Map.keys()
    |> Enum.count()
  end

  def read_program do
    "inputs/day11.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
  end

  def start_program(program) do
    spawn(Day11.IntcodeInterpreter, :start_program, [program, [], self()])
  end

  def iterate(pid, dir \\ :up, pos \\ {0, 0}, hull_map \\ %{}, iteration \\ 0) do
    IO.inspect(iteration, label: "iteration")

    # send current color
    send(pid, {:input, Map.get(hull_map, pos, 0)})

    # get back new color and next direction
    if Process.alive?(pid) do
      color =
        receive do
          {:output, color} ->
            color
            # |> IO.inspect(label: "color")
        end

      hull_map = Map.put(hull_map, pos, color)

      hull_map
      |> Map.keys()
      |> Enum.count()
      |> IO.inspect(label: "current count")

      if Process.alive?(pid) do
        receive do
          {:output, turn} ->
            # turn |> IO.inspect(label: "turn")
            new_dir = next_direction(dir, turn)
            new_pos = next_position(pos, new_dir)
            if Process.alive?(pid), do: iterate(pid, new_dir, new_pos, hull_map, iteration + 1)
        end
      else
        hull_map
      end
    else
      hull_map
    end
  end

  # let's choose to be sane and use cartesian coordinates today
  def next_position({x, y}, :up), do: {x, y + 1}
  def next_position({x, y}, :right), do: {x + 1, y}
  def next_position({x, y}, :down), do: {x, y - 1}
  def next_position({x, y}, :left), do: {x - 1, y}

  def next_direction(:up, 0), do: :left
  def next_direction(:right, 0), do: :up
  def next_direction(:down, 0), do: :right
  def next_direction(:left, 0), do: :down
  def next_direction(:up, 1), do: :right
  def next_direction(:right, 1), do: :down
  def next_direction(:down, 1), do: :left
  def next_direction(:left, 1), do: :up
end
