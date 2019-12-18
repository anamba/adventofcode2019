defmodule Day16.FFT3 do
  @doc """
      iex> Day16.FFT3.part2("03036732577212944063491565474664")
      "84462026"
      iex> Day16.FFT3.part2("02935109699940807407585447034323")
      "78725270"
      iex> Day16.FFT3.part2("03081770884921959731165446850517")
      "53553731"
      iex> Day16.FFT3.part2()
      "16178430"
  """
  def part2(input \\ nil) do
    start = System.monotonic_time(:millisecond)

    input =
      (input || parse_input())
      |> String.trim()
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)

    offset =
      input
      |> Enum.take(7)
      |> Integer.undigits()

    input =
      input
      |> List.duplicate(10000)
      |> List.flatten()
      |> Enum.drop(offset)

    input_len = length(input)

    (System.monotonic_time(:millisecond) - start)
    |> IO.inspect(label: "generated input (length: #{input_len})")

    output = run_partial_sum(input, 100)

    (System.monotonic_time(:millisecond) - start) |> IO.inspect(label: "done")

    output
    |> Enum.take(8)
    |> Enum.join()
    |> IO.inspect(label: "final answer")
  end

  def parse_input(filename \\ "inputs/day16.txt") do
    File.read!(filename)
  end

  def run_partial_sum(input, phases_left \\ 1)
  def run_partial_sum(input, 0), do: input

  def run_partial_sum(input, phases_left) do
    {output, _sum} =
      input
      |> Enum.reverse()
      |> Enum.map_reduce(0, fn el, sum ->
        sum = sum + el
        {abs(rem(sum, 10)), sum}
      end)

    output = Enum.reverse(output)

    run_partial_sum(output, phases_left - 1)
  end
end
