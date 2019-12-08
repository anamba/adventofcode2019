defmodule Day8.SIFDecoder2 do
  def run do
    [str] =
      "inputs/day8.txt"
      |> File.stream!()
      |> Enum.map(fn line -> line |> String.trim() end)

    split_into_layers(str, 25, 6)
    |> compute_final_image
    |> display_image
    |> IO.puts()
  end

  def display_image(image) do
    Enum.map_join(image, "\n", &Enum.join/1)
  end

  @doc """
      iex> Day8.SIFDecoder2.compute_final_image([[[0,2],[2,2]],[[1,1],[2,2]], [[2,2],[1,2]], [[0,0],[0,0]]])
      [[0,1],[1,0]]
  """
  def compute_final_image(layers) do
    height = length(List.first(layers))
    width = length(List.first(layers) |> List.first())

    for y <- 0..(height - 1) do
      for x <- 0..(width - 1) do
        layers
        |> Enum.map(fn layer -> layer |> Enum.at(y) |> Enum.at(x) end)
        |> Enum.find(&(&1 != 2))
      end
    end
  end

  @doc """
      iex> Day8.SIFDecoder2.count_occurrences_by_layer([[[1,1,2,1],[0,0,0,0]],[[2,2,0,2],[2,1,1,1]]])
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
      iex> Day8.SIFDecoder2.split_into_layers("123456789012", 3, 2)
      [[[1,2,3], [4,5,6]], [[7,8,9], [0,1,2]]]
  """
  def split_into_layers(str, w, h) when is_binary(str) do
    split_into_layers(String.graphemes(str) |> Enum.map(&String.to_integer/1), w, h)
  end

  def split_into_layers(digits, w, h) when is_list(digits) do
    layers = div(length(digits), w * h)

    for layer <- 0..(layers - 1) do
      for y <- 0..(h - 1) do
        Enum.slice(digits, layer * w * h + y * w, w)
      end
    end
  end
end
