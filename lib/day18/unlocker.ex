defmodule Day18.Unlocker do
  @doc """
      # iex> Day18.Unlocker.part1("day18-sample1.txt")
      # {86, ["a", "b", "c", "d", "e", "f"]}
      # iex> Day18.Unlocker.part1("day18-sample2.txt")
      # {132, ["b", "a", "c", "d", "f", "e", "g"]}
      # iex> Day18.Unlocker.part1("day18-sample3.txt")
      # {136}
      # iex> Day18.Unlocker.part1("day18-sample4.txt")
      # {81, ["a", "c", "f", "i", "d", "g", "b", "e", "h"]}
      iex> Day18.Unlocker.part1()
      {0, ["a", "c", "d", "g", "f", "i", "b", "e", "h"]}
  """
  def part1(filename \\ "day18.txt") do
    {map, lookup} = read_input(filename)
    pos = lookup["@"]
    {map, lookup} = remove({map, lookup}, "@")

    iterate(pos, {map, lookup})
  end

  def read_input(filename \\ "day18.txt") do
    map =
      File.stream!("inputs/#{filename}")
      |> Enum.with_index()
      |> Enum.map(fn {line, row} ->
        line
        |> String.trim()
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {char, col} -> {{col, row}, char} end)
      end)
      |> List.flatten()
      |> Enum.into(%{})

    lookup =
      File.stream!("inputs/#{filename}")
      |> Enum.with_index()
      |> Enum.map(fn {line, row} ->
        line
        |> String.trim()
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.map(fn {char, col} -> {char, {col, row}} end)
      end)
      |> List.flatten()
      |> Enum.into(%{})

    {map, lookup}
  end

  def remove({map, lookup}, key) do
    pos = lookup[key]

    case pos do
      nil -> {map, lookup}
      # recurse in case there are more than one -- EDIT: no need, doesn't happen
      # _ -> remove({Map.put(map, pos, "."), Map.delete(lookup, key)}, key)
      _ -> {Map.put(map, pos, "."), Map.delete(lookup, key)}
    end
  end

  # remove key and its associated door
  def remove_key({map, lookup}, key) do
    {map, lookup}
    |> remove(key)
    |> remove(String.upcase(key))
  end

  # each step:
  #  0. see which keys are left. if there are no more keys left, we're done
  #  1. follow all possible paths from current location and see which keys we can retrieve (return key, location, min distance to each)
  #  2. execute all possible actions simultaneously and iterate again
  def iterate(current_pos, {map, lookup}, distance_traveled \\ 0, keys_collected \\ []) do
    keys = keys_remaining({map, lookup})

    case available_actions(current_pos, {map, lookup}, keys) do
      [] ->
        {distance_traveled, keys_collected |> Enum.reverse()}

      actions ->
        actions
        |> Enum.map(fn {key, pos, {map, lookup}, distance} ->
          Task.async(Day18.Unlocker, :iterate, [
            pos,
            {map, lookup},
            distance + distance_traveled,
            [key | keys_collected]
          ])
        end)
        |> yield_and_return_first_non_nil()
        |> Enum.sort()
        |> List.first()
    end
  end

  def yield_and_return_first_non_nil(tasks, quota \\ 1, timeout \\ 500, results \\ []) do
    {tasks, results} =
      tasks
      |> Task.yield_many(timeout)
      |> Enum.reduce({[], results}, fn {task, result}, {tasks, results} ->
        if result do
          case result do
            {:ok, nil} -> {tasks, results}
            {:ok, val} -> {tasks, [val | results]}
          end
        else
          {[task | tasks], results}
        end
      end)

    if length(tasks) == 0 || length(results) >= quota do
      Enum.map(tasks, &Task.shutdown(&1, :brutal_kill))
      results
    else
      yield_and_return_first_non_nil(tasks, quota, timeout, results)
    end
  end

  def keys_remaining({_map, lookup}) do
    lookup
    |> Map.keys()
    |> Enum.filter(&String.match?(&1, ~r/[a-z]/))
  end

  # test each key to see if it is reachable, return {key, navigate_to_key}
  def available_actions(current_pos, {map, lookup}, keys) do
    Enum.map(keys, &navigate_to_key(current_pos, {map, lookup}, &1))
    |> Enum.filter(& &1)
  end

  def navigate_to_key({x, y}, {map, lookup}, key, visited \\ %{}, distance_traveled \\ 0) do
    case map[{x, y}] do
      k when k == key ->
        {k, {x, y}, remove_key({map, lookup}, key), distance_traveled}

      "." ->
        [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
        |> Enum.reject(&visited[&1])
        |> Enum.map(fn pos ->
          Task.async(Day18.Unlocker, :navigate_to_key, [
            pos,
            {map, lookup},
            key,
            Map.put(visited, {x, y}, true),
            distance_traveled + 1
          ])
        end)
        |> yield_and_return_first_non_nil()
        |> Enum.filter(& &1)
        |> Enum.sort_by(fn {_, _, _, distance} -> distance end)
        |> List.first()

      # could be: (1) nothing (out of bounds), (2) a wall, (3) a door (blocked) or
      #           (4) another key (meaning this path is not what we're looking for)
      _ ->
        nil
    end
  end
end
