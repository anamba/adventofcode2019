defmodule Day9.Boost do
  def part1 do
    program =
      "inputs/day9.txt"
      |> File.stream!()
      |> Enum.map(fn line ->
        line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
      end)
      |> List.flatten()

    Day9.IntcodeInterpreter.start_program(program, [1])
  end

  def part2 do
    program =
      "inputs/day9.txt"
      |> File.stream!()
      |> Enum.map(fn line ->
        line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
      end)
      |> List.flatten()

    Day9.IntcodeInterpreter.start_program(program, [2])
  end
end
