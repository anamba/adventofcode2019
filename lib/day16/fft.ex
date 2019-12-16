defmodule Day16.FFT do
  @doc """
      iex> Day16.FFT.part1("80871224585914546619083218645595")
      "24176176"
      iex> Day16.FFT.part1("19617804207202209144916044189917")
      "73745418"
      iex> Day16.FFT.part1()
      "61149209"
  """
  def part1(input \\ nil) do
    input =
      (input || parse_input())
      |> String.trim()
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)

    run_fft(input, 100)
    |> Enum.take(8)
    |> Enum.join()
  end

  def parse_input(filename \\ "inputs/day16.txt") do
    File.read!(filename)
  end

  @doc """
      iex> Day16.FFT.produce_pattern(2, 7)
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

  @doc """
      iex> Day16.FFT.run_fft([1,2,3,4,5,6,7,8], 1)
      [4,8,2,2,6,1,5,8]
      iex> Day16.FFT.run_fft([1,2,3,4,5,6,7,8], 2)
      [3,4,0,4,0,4,3,8]
      iex> Day16.FFT.run_fft([1,2,3,4,5,6,7,8], 3)
      [0,3,4,1,5,5,1,8]
      iex> Day16.FFT.run_fft([1,2,3,4,5,6,7,8], 4)
      [0,1,0,2,9,4,9,8]
  """
  def run_fft(input, phases_left \\ 1)
  def run_fft(input, 0), do: input

  def run_fft(input, phases_left) do
    output =
      for i <- 1..length(input) do
        calculate_element(input, i)
      end

    run_fft(output, phases_left - 1)
  end

  @doc """
      iex> Day16.FFT.calculate_element([1,2,3,4,5,6,7,8], 1)
      4
      iex> Day16.FFT.calculate_element([1,2,3,4,5,6,7,8], 2)
      8
  """
  def calculate_element(input, output_pos) do
    pattern = produce_pattern(output_pos, length(input))

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
