defmodule Day15.RepairDroid2 do
  @doc """
       iex> Day15.RepairDroid2.part2
       390
  """
  def part2 do
    memory = read_program()

    # run it until it is ready for input
    {ptr, memory, []} = Day7.IntcodeInterpreter2.start_program(memory, [], 0)

    # first navigate to the oxygen thingy as before
    # then, from there, run another search to find the *longest* path to anywhere (all paths valid)
    [{ptr, memory, pos}] =
      navigate_to_oxygen_system(ptr, memory, [{0, 0}], %{{0, 0} => 1}, [1, 2, 3, 4])
      |> List.flatten()

    find_longest_path(ptr, memory, [pos], %{pos => 1}, [1, 2, 3, 4]) - 1
  end

  def read_program do
    "inputs/day15.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
  end

  def navigate_to_oxygen_system(ptr, memory, current_path, explored, unexplored) do
    unexplored
    |> Enum.map(&evaluate_direction_for_oxygen_system(ptr, memory, current_path, explored, &1))
    |> Enum.filter(& &1)
  end

  def evaluate_direction_for_oxygen_system(
        ptr,
        memory,
        [{x, y} | _] = current_path,
        explored,
        direction
      ) do
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

            navigate_to_oxygen_system(
              ptr,
              memory,
              [new_position | current_path],
              explored,
              next_directions
            )

          2 ->
            # done, success, return machine state
            {ptr, memory, {x, y}}
        end

      _ ->
        # done, failure (we've evaluated this position before)
        nil
    end
  end

  def find_longest_path(ptr, memory, current_path, explored, unexplored) do
    unexplored
    |> Enum.map(&evaluate_direction_for_longest_path(ptr, memory, current_path, explored, &1))
    |> Enum.filter(& &1)
    |> Enum.max()
  end

  def evaluate_direction_for_longest_path(
        ptr,
        memory,
        [{x, y} | _] = current_path,
        explored,
        direction
      ) do
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
            # done
            length(current_path)

          _ ->
            explored = Map.put(explored, new_position, 1)

            find_longest_path(
              ptr,
              memory,
              [new_position | current_path],
              explored,
              next_directions
            )
        end

      _ ->
        # done
        length(current_path)
    end
  end
end
