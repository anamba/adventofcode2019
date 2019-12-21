defmodule Day21.SpringDroidCtrl do
  @doc """
      # iex> Day21.SpringDroidCtrl.part1
      # 19360288
  """
  def part1 do
    pid =
      read_program()
      |> start_program([
        "NOT A T",
        "NOT B J",
        "OR T J",
        "NOT C T",
        "OR T J",
        "AND D J",
        "WALK"
      ])

    clear_screen()

    iterate(pid)
  end

  @doc """
      iex> Day21.SpringDroidCtrl.part2
      1143814750
  """
  def part2 do
    pid =
      read_program()
      |> start_program([
        # make sure we can make the next two jumps
        # either D+H (jump+jump) or D+E (jump+walk)
        "OR D T",
        "AND H T",
        "OR D J",
        "AND E J",
        "OR T J",

        # make sure we can make this jump
        "AND D J",

        # but if we're ok to jump, but there is no hole... don't
        "OR J T",
        "AND A T",
        "AND B T",
        "AND C T",
        "NOT T T",
        "AND T J",

        # start
        "RUN"
      ])

    clear_screen()

    iterate(pid)
  end

  def read_program do
    "inputs/day21.txt"
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
      |> String.to_charlist()

    spawn(Day11.IntcodeInterpreter, :start_program, [program, inputs, self()])
  end

  def clear_screen, do: IO.write(IO.ANSI.clear())

  def paint([x, y, tile]) do
    IO.write(IO.ANSI.cursor(y + 1, x + 1))
    IO.write(tile)
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

  def update_vram_and_cursor(vram, {col, row}, value) do
    case value do
      10 ->
        {vram, {0, row + 1}}

      c when is_integer(c) ->
        paint([col, row, <<c>>])
        {Map.put(vram, {col, row}, <<c>>), {col + 1, row}}
    end
  end
end
