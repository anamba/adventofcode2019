defmodule Day5.IntcodeInterpreter do
  def run do
    "inputs/day5.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
    |> start_program([1])
  end

  @doc """
      iex> Day5.IntcodeInterpreter.start_program([1,0,0,0,99])
      {2, []}
      iex> Day5.IntcodeInterpreter.start_program([1,2,2,0,99])
      {4, []}
      iex> Day5.IntcodeInterpreter.start_program([2,3,0,3,99])
      {2, []}
      iex> Day5.IntcodeInterpreter.start_program([2,4,4,5,99,0])
      {2, []}
      iex> Day5.IntcodeInterpreter.start_program([1,1,1,4,99,5,6,0,99])
      {30, []}
      iex> Day5.IntcodeInterpreter.start_program([3,0,1001,0,5,0,4,0,99], [5])
      {10, [10]}
  """
  def start_program(codes, inputs \\ []) do
    {codes, outputs} = interpret(0, codes, inputs)
    {Enum.at(codes, 0), outputs}
  end

  @doc """
      Break down into opcode + modes (mode list may be incomplete, implying default of 0)

      iex> Day5.IntcodeInterpreter.decompose_instruction(1002)
      {2, [0, 1]}
      iex> Day5.IntcodeInterpreter.decompose_instruction(101)
      {1, [1]}
  """
  def decompose_instruction(int) when is_integer(int) do
    decompose_instruction(Integer.digits(int))
  end

  def decompose_instruction(digits) when is_list(digits) do
    opcode = digits |> Enum.reverse() |> Enum.take(2) |> Enum.reverse() |> Integer.undigits()
    modes = digits |> Enum.reverse() |> Enum.drop(2)
    {opcode, modes}
  end

  @doc """
      iex> Day5.IntcodeInterpreter.get_parameters([1002,4,3,4,33], [4, 3], [0, 1])
      [33, 3]
  """
  def get_parameters(codes, raw_values, modes) do
    for i <- 0..(length(raw_values) - 1) do
      raw_value = Enum.at(raw_values, i)
      mode = Enum.at(modes, i, 0)

      case mode do
        0 -> Enum.at(codes, raw_value)
        1 -> raw_value
      end
    end
  end

  @doc """
      iex> Day5.IntcodeInterpreter.interpret(0, [1,0,0,0,99])
      {[2,0,0,0,99], []}
      iex> Day5.IntcodeInterpreter.interpret(0, [1002,4,3,4,33])
      {[1002,4,3,4,99], []}
      iex> Day5.IntcodeInterpreter.interpret(0, [2,3,0,3,99])
      {[2,3,0,6,99], []}
      iex> Day5.IntcodeInterpreter.interpret(0, [2,4,4,5,99,0])
      {[2,4,4,5,99,9801], []}
      iex> Day5.IntcodeInterpreter.interpret(0, [1,1,1,4,99,5,6,0,99])
      {[30,1,1,4,2,5,6,0,99], []}
  """
  def interpret(ptr, codes, inputs \\ [], outputs \\ []) do
    {opcode, modes} = Enum.at(codes, ptr) |> decompose_instruction

    case opcode do
      # add
      1 ->
        args = get_parameters(codes, Enum.slice(codes, ptr + 1, 2), modes)
        target = Enum.at(codes, ptr + 3)
        interpret(ptr + 4, List.replace_at(codes, target, do_add(args)), inputs, outputs)

      # mult
      2 ->
        args = get_parameters(codes, Enum.slice(codes, ptr + 1, 2), modes)
        target = Enum.at(codes, ptr + 3)
        interpret(ptr + 4, List.replace_at(codes, target, do_mult(args)), inputs, outputs)

      # store
      3 ->
        [input | inputs] = inputs
        target = Enum.at(codes, ptr + 1)
        interpret(ptr + 2, List.replace_at(codes, target, input), inputs, outputs)

      # print
      4 ->
        target = Enum.at(codes, ptr + 1)
        output = Enum.at(codes, target)
        outputs = outputs ++ [output]
        interpret(ptr + 2, codes, inputs, outputs)

      # halt
      99 ->
        {codes, outputs}
    end
  end

  def do_add([a, b]), do: a + b
  def do_mult([a, b]), do: a * b
end
