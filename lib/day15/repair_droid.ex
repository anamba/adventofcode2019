defmodule Day15.RepairDroid do
  @doc """
       iex> Day15.RepairDroid.part1
       318
  """
  def part1 do
    memory = read_program()

    # run it until it is ready for input
    {ptr, memory, []} = Day7.IntcodeInterpreter2.start_program(memory, [], 0)

    # start at 0,0
    # take all possible paths at once. path ends when we hit a wall or oxygen system
    # return the shortest one
    iterate(ptr, memory, [{0, 0}], %{{0, 0} => 1}, [1, 2, 3, 4])
    |> List.flatten()
    |> Enum.count()
  end

  def read_program do
    "inputs/day15.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
  end

  def iterate(ptr, memory, current_path, explored, unexplored) do
    unexplored
    |> Enum.map(&evaluate_direction(ptr, memory, current_path, explored, &1))
    |> Enum.filter(& &1)
  end

  def evaluate_direction(ptr, memory, [{x, y} | _] = current_path, explored, direction) do
    {new_position, next_directions} =
      case direction do
        1 -> {{x, y - 1}, [1, 3, 4]}
        2 -> {{x, y + 1}, [2, 3, 4]}
        3 -> {{x - 1, y}, [1, 2, 3]}
        4 -> {{x + 1, y}, [1, 2, 4]}
      end

    case explored[new_position] do
      nil ->
        {ptr, memory, [output]} = Day7.IntcodeInterpreter2.start_program(memory, [direction], ptr)

        case output do
          0 ->
            # done, failure
            nil

          1 ->
            explored = Map.put(explored, new_position, 1)
            iterate(ptr, memory, [new_position | current_path], explored, next_directions)

          2 ->
            # done, success
            current_path
        end

      _ ->
        # done, failure (we've evaluated this position before)
        nil
    end
  end
end
