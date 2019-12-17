defmodule Day17Test do
  use ExUnit.Case

  @tag timeout: 5000
  doctest Day17.ASCII

  @tag timeout: :infinity
  doctest Day17.ASCII2
end
