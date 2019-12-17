defmodule Day17.ASCII do
  @doc """
      iex> Day17.ASCII.part1()
      4044
  """
  def part1 do
    pid = read_program() |> start_program

    clear_screen()

    iterate(pid)
    |> find_intersections
    |> calculate_alignment_parameters
    |> Enum.sum()
  end

  def read_program do
    "inputs/day17.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
  end

  def start_program(program) do
    spawn(Day11.IntcodeInterpreter, :start_program, [program, [], self()])
  end

  def iterate(pid, vram \\ %{}, cursor \\ {0, 0}) do
    receive do
      {:output, value} ->
        {vram, cursor} = update_vram_and_cursor(vram, cursor, value)
        iterate(pid, vram, cursor)
    after
      100 ->
        if Process.alive?(pid) do
          # continue, maybe it was just slow
          iterate(pid, vram, cursor)
        else
          # exit and display
          vram
        end
    end
  end

  def clear_screen, do: IO.write(IO.ANSI.clear())

  def paint([x, y, tile]) do
    IO.write(IO.ANSI.cursor(y + 1, x + 1))
    IO.write(tile)
  end

  def update_vram_and_cursor(vram, {col, row}, value) do
    case value do
      10 ->
        {vram, {0, row + 1}}

      c when is_integer(c) ->
        paint([col, row, <<c>>])
        {Map.put(vram, {col, row}, <<c>>), {col + 1, row}}
    end
  end

  def find_intersections(vram) do
    vram
    |> Map.keys()
    |> Enum.filter(&is_intersection(&1, vram))
  end

  def is_intersection({col, row}, vram) do
    vram[{col - 1, row}] == "#" &&
      vram[{col + 1, row}] == "#" &&
      vram[{col, row - 1}] == "#" &&
      vram[{col, row + 1}] == "#"
  end

  def calculate_alignment_parameters(list) do
    list
    |> Enum.map(fn {col, row} -> col * row end)
  end
end
