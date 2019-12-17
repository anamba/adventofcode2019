defmodule Day17.ASCII2 do
  @doc """
      iex> Day17.ASCII2.part2()
      893283
  """
  def part2 do
    pid =
      read_program()
      |> start_program([
        "A,B,A,C,A,B,C,B,C,B",
        "R,8,L,10,L,12,R,4",
        "R,8,L,12,R,4,R,4",
        "R,8,L,10,R,8",
        "n"
      ])

    clear_screen()

    iterate(pid)
  end

  def read_program do
    "inputs/day17a.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
  end

  def start_program(program, inputs) do
    inputs =
      inputs
      |> Enum.map_join(&Kernel.<>(&1, "\n"))
      |> String.to_char_list()

    spawn(Day11.IntcodeInterpreter, :start_program, [program, inputs, self()])
  end

  def iterate(pid, vram \\ %{}, cursor \\ {0, 0}) do
    receive do
      {:output, value} when value < 256 ->
        {vram, cursor} = update_vram_and_cursor(vram, cursor, value)
        iterate(pid, vram, cursor)

      {:output, value} ->
        value
    after
      100 ->
        if Process.alive?(pid) do
          # continue, maybe it was just slow
          iterate(pid, vram, cursor)
        else
          # exit
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
        {vram, {0, rem(row + 1, 50)}}

      c when is_integer(c) ->
        paint([col, row, <<c>>])
        {Map.put(vram, {col, row}, <<c>>), {col + 1, row}}
    end
  end
end
