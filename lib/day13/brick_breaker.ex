defmodule Day13.BrickBreaker do
  def part1 do
    pid = read_program() |> start_program

    final = iterate(pid)

    final
    |> Map.values()
    |> Enum.filter(&(&1 == 2))
    |> Enum.count()
  end

  def read_program do
    "inputs/day13.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
  end

  def start_program(program) do
    spawn(Day11.IntcodeInterpreter, :start_program, [program, [], self()])
  end

  def iterate(pid, vram \\ %{}, buffer \\ []) do
    receive do
      {:output, value} ->
        buffer = buffer ++ [value]

        if length(buffer) == 3 do
          # interpret and draw to vram
          iterate(pid, update_vram(vram, buffer), [])
        else
          # carry on
          iterate(pid, vram, buffer)
        end
    after
      100 ->
        if Process.alive?(pid) do
          # continue, maybe it was just slow
          iterate(pid, vram, buffer)
        else
          # exit and display
          vram
        end
    end
  end

  def update_vram(vram, [x, y, tile]) do
    Map.put(vram, {x, y}, tile)
  end
end
