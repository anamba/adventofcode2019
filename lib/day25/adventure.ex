defmodule Day25.Adventure do
  def part1 do
    read_program()
    |> start_program
    |> manage_program_io
  end

  def read_program do
    "inputs/day25.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
  end

  def start_program(program, inputs \\ []) do
    spawn(Day25.IntcodeInterpreter, :start_program, [program, inputs, self()])
  end

  def manage_program_io(pid) do
    receive do
      {:output, _, value} when value < 256 ->
        IO.write(<<value>>)
        manage_program_io(pid)

      {:input, _} ->
        case IO.gets("") do
          "n\n" -> "north\n"
          "s\n" -> "south\n"
          "e\n" -> "east\n"
          "w\n" -> "west\n"
          str -> str
        end
        |> String.to_charlist()
        |> Enum.map(fn c -> send(pid, c) end)

        manage_program_io(pid)

      {:output, _, value} ->
        value
    after
      100 ->
        # continue, maybe it was just slow
        if Process.alive?(pid) do
          manage_program_io(pid)
        else
          # exit
          IO.puts("Intcode program exited.")
        end
    end
  end
end
