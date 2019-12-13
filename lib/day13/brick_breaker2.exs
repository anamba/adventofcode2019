# to run:
# elixir -r lib/day11/intcode_interpreter.ex lib/day13/brick_breaker2.exs
defmodule Day13.BrickBreaker2 do
  def part2 do
    pid = read_program() |> start_program

    clear_screen()

    {_vram, score} = iterate(pid)
    score
  end

  def read_program do
    "inputs/day13a.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
  end

  def start_program(program) do
    spawn(Day11.IntcodeInterpreter, :start_program, [program, [], self()])
  end

  def iterate(pid, ball_pos \\ nil, paddle_pos \\ nil, vram \\ %{}, buffer \\ [], score \\ 0) do
    receive do
      {:output, value} ->
        buffer = buffer ++ [value]

        if length(buffer) == 3 do
          case buffer do
            [-1, 0, new_score] ->
              iterate(pid, ball_pos, paddle_pos, vram, [], new_score)

            [x, y, tile] ->
              {ball_pos, paddle_pos} =
                case tile do
                  3 ->
                    {ball_pos, {x, y}}

                  4 ->
                    new_ball_pos = {x, y}

                    if paddle_pos do
                      {px, py} = paddle_pos

                      cond do
                        px < x -> send(pid, {:input, 1})
                        px > x -> send(pid, {:input, -1})
                        true -> nil
                      end
                    end

                    {new_ball_pos, paddle_pos}

                  _ ->
                    {ball_pos, paddle_pos}
                end

              # interpret and draw to vram
              iterate(pid, ball_pos, paddle_pos, update_vram(vram, buffer), [], score)
          end
        else
          # carry on
          iterate(pid, ball_pos, paddle_pos, vram, buffer, score)
        end
    after
      500 ->
        if Process.alive?(pid) do
          # give it an input to keep things moving
          send(pid, {:input, 0})

          # continue
          iterate(pid, ball_pos, paddle_pos, vram, buffer, score)
        else
          # exit and display
          {vram, score}
        end
    end
  end

  def clear_screen, do: IO.write(IO.ANSI.clear())

  def paint([x, y, tile]) do
    IO.write(IO.ANSI.cursor(y, x + 1))

    case(tile) do
      0 -> " "
      1 -> "|"
      2 -> "="
      3 -> "_"
      4 -> "o"
    end
    |> IO.write()
  end

  def read_vram(vram, pos = {_x, _y}) do
    Map.get(vram, pos, 0)
  end

  def update_vram(vram, [x, y, tile]) do
    paint([x, y, tile])
    Map.put(vram, {x, y}, tile)
  end
end

IO.puts(Day13.BrickBreaker2.part2())
