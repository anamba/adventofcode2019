defmodule Day16.FFT2 do
  @doc """
      iex> Day16.FFT2.part1("80871224585914546619083218645595")
      "24176176"
      iex> Day16.FFT2.part1("19617804207202209144916044189917")
      "73745418"
      iex> Day16.FFT2.part1()
      "61149209"
  """
  def part1(input \\ nil) do
    input =
      (input || parse_input())
      |> String.trim()
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)

    start = System.monotonic_time(:millisecond)

    input_len = length(input)

    patterns =
      1..input_len
      |> Enum.map(&produce_pattern(&1, input_len))

    (System.monotonic_time(:millisecond) - start) |> IO.inspect(label: "generated patterns")

    output =
      run_fft(input, patterns, 100)
      |> Enum.take(8)
      |> Enum.join()

    (System.monotonic_time(:millisecond) - start) |> IO.inspect(label: "done")

    output
  end

  @doc """
      # iex> Day16.FFT2.part2("03036732577212944063491565474664")
      # "84462026"
      # iex> Day16.FFT2.part2("02935109699940807407585447034323")
      # "78725270"
      # iex> Day16.FFT2.part2("03081770884921959731165446850517")
      # "53553731"
      # iex> Day16.FFT2.part2()
      # "61149209"
  """
  def part2(input \\ nil) do
    input =
      (input || parse_input())
      |> String.trim()
      |> String.duplicate(20)
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)

    start = System.monotonic_time(:millisecond)

    input_len = length(input)

    patterns =
      1..input_len
      |> Enum.map(&produce_pattern(&1, input_len))

    (System.monotonic_time(:millisecond) - start) |> IO.inspect(label: "generated patterns")

    output = run_fft(input, patterns, 100)

    offset = 0
    #   output
    # |> Enum.take(7)
    # |> Integer.undigits()

    (System.monotonic_time(:millisecond) - start) |> IO.inspect(label: "done")

    output
    |> Enum.drop(offset)
    |> Enum.take(8)
    |> Enum.join()
  end

  def parse_input(filename \\ "inputs/day16.txt") do
    File.read!(filename)
  end

  @doc """
      iex> Day16.FFT2.produce_pattern(2, 7)
      [0, 1, 1, 0, 0, -1, -1]
  """
  def produce_pattern(pos, len) do
    pattern = [0, 1, 0, -1]

    for i <- 1..4 do
      Enum.at(pattern, i - 1)
      |> List.duplicate(pos)
    end
    |> List.flatten()
    |> multiply_to_length(len + 1)
    |> Enum.drop(1)
  end

  def run_fft(input, patterns, phases_left \\ 1)
  def run_fft(input, _patterns, 0), do: input

  def run_fft(input, patterns, phases_left) do
    output = Enum.map(patterns, &calculate_element(input, &1))
    run_fft(output, patterns, phases_left - 1)
  end

  def calculate_element(input, pattern) do
    Matrix.emult([input], [pattern])
    |> List.flatten()
    |> Enum.sum()
    |> rem(10)
    |> abs
  end

  def multiply_to_length(pattern, len) when length(pattern) == len, do: pattern
  def multiply_to_length(pattern, len) when length(pattern) > len, do: Enum.take(pattern, len)

  def multiply_to_length(pattern, len) do
    pattern
    |> List.duplicate(ceil(len / length(pattern)))
    |> List.flatten()
    |> Enum.take(len)
  end
end
