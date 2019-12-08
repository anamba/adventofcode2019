defmodule Day8.SIFDecoder do
  def run do
    [str] =
      "inputs/day8.txt"
      |> File.stream!()
      |> Enum.map(fn line -> line |> String.trim() end)

    layer =
      decode(str, 25, 6)
      |> count_occurrences_by_layer()
      |> Enum.sort_by(& &1[0])
      |> List.first()

    layer[1] * layer[2]
  end

  @doc """
      iex> Day8.SIFDecoder.count_occurrences_by_layer([[[1,1,2,1],[0,0,0,0]],[[2,2,0,2],[2,1,1,1]]])
      [%{0 => 4, 1 => 3, 2 => 1}, %{0 => 1, 1 => 3, 2 => 4}]
  """
  def count_occurrences_by_layer(layers) do
    layers
    |> Enum.map(&List.flatten/1)
    |> Enum.map(&count_occurrences/1)
  end

  def count_occurrences(layer) do
    layer
    |> Enum.group_by(& &1)
    |> Enum.map(fn {k, v} -> {k, length(v)} end)
    |> Enum.into(%{})
  end

  @doc """
      iex> Day8.SIFDecoder.decode("123456789012", 3, 2)
      [[[1,2,3], [4,5,6]], [[7,8,9], [0,1,2]]]
  """
  def decode(str, w, h) when is_binary(str) do
    decode(String.graphemes(str) |> Enum.map(&String.to_integer/1), w, h)
  end

  def decode(digits, w, h) when is_list(digits) do
    layers = div(length(digits), w * h)

    for layer <- 0..(layers - 1) do
      for y <- 0..(h - 1) do
        Enum.slice(digits, layer * w * h + y * w, w)
      end
    end
  end
end
