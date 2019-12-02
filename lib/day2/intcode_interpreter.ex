defmodule Day2.IntcodeInterpreter do
  def run do
    "inputs/day2.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
    |> start_program("1202")
  end

  @doc """
      iex> Day2.IntcodeInterpreter.start_program([1,0,0,0,99])
      2
      iex> Day2.IntcodeInterpreter.start_program([1,2,2,0,99])
      4
      iex> Day2.IntcodeInterpreter.start_program([1,0,0,0,99], "0202")
      4
      iex> Day2.IntcodeInterpreter.start_program([2,3,0,3,99])
      2
      iex> Day2.IntcodeInterpreter.start_program([2,4,4,5,99,0])
      2
      iex> Day2.IntcodeInterpreter.start_program([1,1,1,4,99,5,6,0,99])
      30
  """
  def start_program(codes) do
    interpret(0, codes)
    |> Enum.at(0)
  end

  def start_program(codes, replacements_str) when is_binary(replacements_str) do
    replacements_i = String.to_integer(replacements_str)
    replacements = [nil, div(replacements_i, 100), rem(replacements_i, 100)]

    # there must be a better way to do this...
    updated_codes =
      for i <- 0..(length(codes) - 1) do
        replacement = Enum.at(replacements, i)
        if replacement, do: replacement, else: Enum.at(codes, i)
      end

    start_program(updated_codes)
  end

  @doc """
      iex> Day2.IntcodeInterpreter.interpret(0, [1,0,0,0,99])
      [2,0,0,0,99]
      iex> Day2.IntcodeInterpreter.interpret(0, [2,3,0,3,99])
      [2,3,0,6,99]
      iex> Day2.IntcodeInterpreter.interpret(0, [2,4,4,5,99,0])
      [2,4,4,5,99,9801]
      iex> Day2.IntcodeInterpreter.interpret(0, [1,1,1,4,99,5,6,0,99])
      [30,1,1,4,2,5,6,0,99]
  """
  def interpret(ptr, codes) do
    instruction = Enum.at(codes, ptr)

    case instruction do
      1 ->
        args = Enum.slice(codes, ptr + 1, 2) |> Enum.map(fn n -> Enum.at(codes, n) end)
        target = Enum.at(codes, ptr + 3)
        interpret(ptr + 4, List.replace_at(codes, target, do_add(args)))

      2 ->
        args = Enum.slice(codes, ptr + 1, 2) |> Enum.map(fn n -> Enum.at(codes, n) end)
        target = Enum.at(codes, ptr + 3)
        interpret(ptr + 4, List.replace_at(codes, target, do_mult(args)))

      99 ->
        codes
    end
  end

  def do_add([a, b]), do: a + b
  def do_mult([a, b]), do: a * b
end
