defmodule Day23.Networking do
  @doc """
      iex> Day23.Networking1.part1
      0
  """
  def part1 do
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

  def iterate(pids, buffers \\ %{}, nat_value \\ 0) do
    receive do
      {:output, sender, value} ->
        buffer = [value | Map.get(buffers, sender, [])]

        if length(buffer) == 3 do
          sender_index = Enum.find_index(pids, &(&1 == sender))
          send_packet(pids, sender_index, Enum.reverse(buffer))
          iterate(pids, Map.put(buffers, sender, []))
        else
          # carry on
          iterate(pids, Map.put(buffers, sender, buffer))
        end
    after
      1000 ->
        IO.puts("timeout")

        # continue, maybe it was just slow
        if Enum.any?(pids, &Process.alive?(&1)) do
          iterate(pids, buffers)
        else
          # exit
        end
    end
  end

  def send_packet(pids, sender, [address, x, y]) do
    case address do
      255 ->
        IO.puts(y)

      n when n < 0 ->
        IO.puts("Could not send to non-existent address #{address}")

      _ ->
        pid = Enum.at(pids, address)

        if pid do
          if Process.alive?(pid) do
            IO.puts("Sending (#{x},#{y}) from #{sender} to #{address}")
            send(pid, x)
            send(pid, y)
          else
            IO.puts("Send to address #{address} failed, process not alive")
          end
        else
          IO.puts("Could not send to non-existent address #{address}")
        end
    end
  end
end
