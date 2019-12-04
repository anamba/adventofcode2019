defmodule Day4.PasswordFinder do
  def run do
    [first, last] =
      "inputs/day4.txt"
      |> File.stream!()
      |> Enum.flat_map(fn line ->
        line |> String.trim() |> parse_range()
      end)

    first..last
    |> Stream.map(&valid_password?/1)
    |> Enum.count(fn x -> x end)
  end

  @doc """
      iex> Day4.PasswordFinder.parse_range("146810-612564")
      [146_810, 612_564]
  """
  def parse_range(str) when is_binary(str) do
    String.split(str, "-")
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
      iex> Day4.PasswordFinder.valid_password?("111111")
      true
      iex> Day4.PasswordFinder.valid_password?("223450")
      false
      iex> Day4.PasswordFinder.valid_password?("123789")
      false
  """
  def valid_password?(str) when is_binary(str) do
    digits = String.graphemes(str) |> Enum.map(&String.to_integer/1)
    has_adjacent_repeating_digits?(digits) && all_digits_same_or_increasing_ltor?(digits)
  end

  def valid_password?(int) when is_integer(int), do: valid_password?(Integer.to_string(int))

  def has_adjacent_repeating_digits?(digits) do
    digits
    |> Enum.chunk_every(2, 1)
    |> Enum.any?(fn
      [x, y] -> x == y
      _ -> false
    end)
  end

  def all_digits_same_or_increasing_ltor?(digits) do
    digits
    |> Enum.chunk_every(2, 1)
    |> Enum.all?(fn
      [x, y] -> x <= y
      _ -> true
    end)
  end
end
