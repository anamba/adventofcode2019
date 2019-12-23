defmodule Day23.Networking2 do
  @doc """
      iex> Day23.Networking2.part2
      0
  """
  def part2 do
    program = read_program()

    pids =
      0..49
      |> Enum.map(&start_program(program, [&1]))

    iterate(pids)
  end

  def read_program do
    "inputs/day23.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
  end

  def start_program(program, inputs \\ []) do
    spawn(Day23.IntcodeInterpreter, :start_program, [program, inputs, self()])
  end

  def iterate(pids, buffers \\ %{}, nat_value \\ nil) do
    receive do
      {:output, sender, value} ->
        buffer = [value | Map.get(buffers, sender, [])]

        if length(buffer) == 3 do
          sender_index = Enum.find_index(pids, &(&1 == sender))
          nat_value = send_packet(pids, sender_index, Enum.reverse(buffer), nat_value)
          iterate(pids, Map.put(buffers, sender, []), nat_value)
        else
          # carry on
          iterate(pids, Map.put(buffers, sender, buffer), nat_value)
        end
    after
      100 ->
        IO.puts("timeout, sending nat value")

        nat_value =
          case nat_value do
            {x, y} ->
              send_packet(pids, -1, [0, x, y], nat_value)

            _ ->
              nat_value
          end

        # continue, maybe it was just slow
        if Enum.any?(pids, &Process.alive?(&1)) do
          iterate(pids, buffers, nat_value)
        else
          # exit
        end
    end
  end

  def send_packet(pids, sender, [address, x, y], nat_value) do
    case address do
      255 ->
        if nat_value == {x, y} do
          IO.puts(y)
        else
          {x, y}
        end

      n when n < 0 ->
        IO.puts("Could not send to non-existent address #{address}")

      _ ->
        pid = Enum.at(pids, address)

        if pid do
          if Process.alive?(pid) do
            IO.puts("Sending (#{x},#{y}) from #{sender} to #{address}")
            send(pid, x)
            send(pid, y)
            nat_value
          else
            IO.puts("Send to address #{address} failed, process not alive")
          end
        else
          IO.puts("Could not send to non-existent address #{address}")
        end
    end
  end
end
