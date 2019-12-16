defmodule Day16.FFT2a do
  @doc """
      # iex> Day16.FFT2.part1("80871224585914546619083218645595")
      # "24176176"
      # iex> Day16.FFT2.part1("19617804207202209144916044189917")
      # "73745418"
      # iex> Day16.FFT2.part1()
      # "61149209a"
  """
  def part1(input \\ nil) do
    input =
      (input || parse_input())
      |> String.trim()
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)

    patterns = produce_multiplier_list([0, 1, 0, -1], length(input))

    output = run_fft(input, patterns, 100)

    offset = 0
    #   output
    # |> Enum.take(7)
    # |> Integer.undigits()

    output
    |> Enum.drop(offset)
    |> Enum.take(8)
    |> Enum.join()
  end

  def parse_input(filename \\ "inputs/day16.txt") do
    File.read!(filename)
  end

  def produce_multiplier_list(pattern, limit) do
    for i <- 1..limit do
      produce_pattern(pattern, i)
    end
  end

  @doc """
      iex> Day16.FFT2.produce_pattern([0, 1, 0, -1], 2)
      1
  """
  def produce_pattern(pattern, input_pos) do
    pattern =
      for i <- 1..length(pattern) do
        Enum.at(pattern, i - 1)
        |> List.duplicate(input_pos)
      end
      |> List.flatten()
      |> IO.inspect()

    # skipping the first element in the pattern is like 1-indexing a 0-indexed list... convenient
    pattern_pos = rem(input_pos, length(pattern)) |> IO.inspect()
    Enum.at(pattern, pattern_pos)
  end

  @doc """
      # iex> Day16.FFT2.run_fft([1,2,3,4,5,6,7,8], Day16.FFT2.produce_multiplier_list([0, 1, 0, -1], 8), 1)
      # [4,8,2,2,6,1,5,8]
      # iex> Day16.FFT2.run_fft([1,2,3,4,5,6,7,8], Day16.FFT2.produce_multiplier_list([0, 1, 0, -1], 8), 2)
      # [3,4,0,4,0,4,3,8]
      # iex> Day16.FFT2.run_fft([1,2,3,4,5,6,7,8], Day16.FFT2.produce_multiplier_list([0, 1, 0, -1], 8), 3)
      # [0,3,4,1,5,5,1,8]
      # iex> Day16.FFT2.run_fft([1,2,3,4,5,6,7,8], Day16.FFT2.produce_multiplier_list([0, 1, 0, -1], 8), 4)
      # [0,1,0,2,9,4,9,8]
  """
  def run_fft(input, patterns, phases_left \\ 1)
  def run_fft(input, _patterns, 0), do: input

  def run_fft(input, patterns, phases_left) do
    output =
      for i <- 1..length(input) do
        calculate_element(input, i, patterns)
      end

    run_fft(output, patterns, phases_left - 1)
  end

  @doc """
      iex> Day16.FFT2.calculate_element([1,2,3,4,5,6,7,8], 1, Day16.FFT2.produce_multiplier_list([0, 1, 0, -1], 8))
      4
      iex> Day16.FFT2.calculate_element([1,2,3,4,5,6,7,8], 2, Day16.FFT2.produce_multiplier_list([0, 1, 0, -1], 8))
      8
  """
  def calculate_element(input, output_pos, patterns) do
    multiplier = Enum.at(patterns, output_pos - 1)

    input
    |> Enum.map(&(&1 * multiplier))
    |> Enum.sum()
    |> rem(10)
    |> abs
  end
end
