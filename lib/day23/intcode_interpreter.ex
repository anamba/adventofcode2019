defmodule Day23.IntcodeInterpreter do
  @doc """
      iex> Day23.IntcodeInterpreter.start_program([3,0,1001,0,5,0,4,0,99], [5])
      {nil, [10]}
      iex> Day23.IntcodeInterpreter.start_program([3,9,8,9,10,9,4,9,99,-1,8], [8])
      {nil, [1]}
      iex> Day23.IntcodeInterpreter.start_program([3,9,8,9,10,9,4,9,99,-1,8], [4])
      {nil, [0]}
      iex> Day23.IntcodeInterpreter.start_program([3,9,7,9,10,9,4,9,99,-1,8], [8])
      {nil, [0]}
      iex> Day23.IntcodeInterpreter.start_program([3,9,7,9,10,9,4,9,99,-1,8], [-8])
      {nil, [1]}
      iex> Day23.IntcodeInterpreter.start_program([3,3,1108,-1,8,3,4,3,99], [8])
      {nil, [1]}
      iex> Day23.IntcodeInterpreter.start_program([3,3,1108,-1,8,3,4,3,99], [5])
      {nil, [0]}
      iex> Day23.IntcodeInterpreter.start_program([3,3,1107,-1,8,3,4,3,99], [8])
      {nil, [0]}
      iex> Day23.IntcodeInterpreter.start_program([3,3,1107,-1,8,3,4,3,99], [-8])
      {nil, [1]}
      iex> Day23.IntcodeInterpreter.start_program([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], [0])
      {nil, [0]}
      iex> Day23.IntcodeInterpreter.start_program([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], [1])
      {nil, [1]}
      iex> Day23.IntcodeInterpreter.start_program([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], [0])
      {nil, [0]}
      iex> Day23.IntcodeInterpreter.start_program([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], [1])
      {nil, [1]}
      iex> Day23.IntcodeInterpreter.start_program([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], [8])
      {nil, [1000]}
      iex> Day23.IntcodeInterpreter.start_program([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], [9])
      {nil, [1001]}
      iex> Day23.IntcodeInterpreter.start_program([3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99], [7])
      {nil, [999]}
      iex> Day23.IntcodeInterpreter.start_program([1102,34915192,34915192,7,4,7,99,0])
      {nil, [1219070632396864]}
      iex> Day23.IntcodeInterpreter.start_program([104,1125899906842624,99])
      {nil, [1125899906842624]}
      iex> Day23.IntcodeInterpreter.start_program([109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99])
      {nil, [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]}
  """
  def start_program(codes, inputs \\ [], outputs_or_pid \\ []) do
    {ptr, _codes, outputs} = interpret(0, codes, inputs, outputs_or_pid)
    {ptr, outputs}
  end

  @doc """
      Break down into opcode + modes (mode list may be incomplete, implying default of 0)

      iex> Day23.IntcodeInterpreter.decompose_instruction(1002)
      {2, [0, 1]}
      iex> Day23.IntcodeInterpreter.decompose_instruction(101)
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
      iex> Day23.IntcodeInterpreter.get_values([1002,4,3,4,33], [4, 3], [0, 1], 0)
      [33, 3]
  """
  def get_values(codes, raw_values, modes, relative_base) do
    for i <- 0..(length(raw_values) - 1) do
      raw_value = Enum.at(raw_values, i)
      mode = Enum.at(modes, i, 0)

      case mode do
        0 -> Enum.at(codes, raw_value, 0)
        1 -> raw_value
        2 -> Enum.at(codes, raw_value + relative_base, 0)
      end
    end
  end

  @doc """
      iex> Day23.IntcodeInterpreter.store_value_at([0], 0, 1)
      [1]
      iex> Day23.IntcodeInterpreter.store_value_at([], 0, 1)
      [1]
      iex> Day23.IntcodeInterpreter.store_value_at([], 10, 1)
      [0,0,0,0,0,0,0,0,0,0,1]
  """
  def store_value_at(memory, location, value) when length(memory) <= location do
    store_value_at(memory ++ List.duplicate(0, location - length(memory) + 1), location, value)
  end

  def store_value_at(memory, location, value) do
    List.replace_at(memory, location, value)
  end

  @doc """
      iex> Day23.IntcodeInterpreter.interpret(0, [1,0,0,0,99])
      {nil, [2,0,0,0,99], []}
      iex> Day23.IntcodeInterpreter.interpret(0, [1002,4,3,4,33])
      {nil, [1002,4,3,4,99], []}
      iex> Day23.IntcodeInterpreter.interpret(0, [2,3,0,3,99])
      {nil, [2,3,0,6,99], []}
      iex> Day23.IntcodeInterpreter.interpret(0, [2,4,4,5,99,0])
      {nil, [2,4,4,5,99,9801], []}
      iex> Day23.IntcodeInterpreter.interpret(0, [1,1,1,4,99,5,6,0,99])
      {nil, [30,1,1,4,2,5,6,0,99], []}
      iex> Day23.IntcodeInterpreter.interpret(0, [22201,1,2,6,203,-1,99,-1], [1234], [], 1)
      {nil, [1234,1,2,6,203,-1,99,8], []}
  """
  def interpret(ptr, codes, inputs \\ [], outputs_or_pid \\ [], relative_base \\ 0) do
    {opcode, modes} = Enum.at(codes, ptr) |> decompose_instruction

    {outputs, receiver_pid} =
      case outputs_or_pid do
        outputs when is_list(outputs) -> {outputs, nil}
        pid when is_pid(pid) -> {nil, pid}
      end

    case opcode do
      # add/3
      1 ->
        [a, b] = get_values(codes, Enum.slice(codes, ptr + 1, 2), modes, relative_base)

        store_target =
          Enum.at(codes, ptr + 3) + if(Enum.at(modes, 2, 0) == 2, do: relative_base, else: 0)

        interpret(
          ptr + 4,
          store_value_at(codes, store_target, a + b),
          inputs,
          outputs_or_pid,
          relative_base
        )

      # mult/3
      2 ->
        [a, b] = get_values(codes, Enum.slice(codes, ptr + 1, 2), modes, relative_base)

        store_target =
          Enum.at(codes, ptr + 3) + if(Enum.at(modes, 2, 0) == 2, do: relative_base, else: 0)

        interpret(
          ptr + 4,
          store_value_at(codes, store_target, a * b),
          inputs,
          outputs_or_pid,
          relative_base
        )

      # input/1
      3 ->
        {input, inputs} =
          case inputs do
            [input | inputs] ->
              {input, inputs}

            [] ->
              # block until we receive input
              receive do
                input -> {input, []}
              after
                100 ->
                  {-1, []}
              end
          end

        store_target =
          Enum.at(codes, ptr + 1) + if(Enum.at(modes, 0, 0) == 2, do: relative_base, else: 0)

        interpret(
          ptr + 2,
          store_value_at(codes, store_target, input),
          inputs,
          outputs_or_pid,
          relative_base
        )

      # output/1
      4 ->
        [output] = get_values(codes, Enum.slice(codes, ptr + 1, 1), modes, relative_base)

        outputs_or_pid =
          cond do
            outputs ->
              outputs ++ [output]

            true ->
              send(receiver_pid, {:output, self(), output})
              receiver_pid
          end

        interpret(ptr + 2, codes, inputs, outputs_or_pid, relative_base)

      # if/2
      5 ->
        [test, jump_target] =
          get_values(codes, Enum.slice(codes, ptr + 1, 2), modes, relative_base)

        if test != 0 do
          interpret(jump_target, codes, inputs, outputs_or_pid, relative_base)
        else
          interpret(ptr + 3, codes, inputs, outputs_or_pid, relative_base)
        end

      # unless/2
      6 ->
        [test, jump_target] =
          get_values(codes, Enum.slice(codes, ptr + 1, 2), modes, relative_base)

        if test == 0 do
          interpret(jump_target, codes, inputs, outputs_or_pid, relative_base)
        else
          interpret(ptr + 3, codes, inputs, outputs_or_pid, relative_base)
        end

      # less than/3
      7 ->
        [test1, test2] = get_values(codes, Enum.slice(codes, ptr + 1, 2), modes, relative_base)

        store_target =
          Enum.at(codes, ptr + 3) + if(Enum.at(modes, 2, 0) == 2, do: relative_base, else: 0)

        codes = store_value_at(codes, store_target, if(test1 < test2, do: 1, else: 0))
        interpret(ptr + 4, codes, inputs, outputs_or_pid, relative_base)

      # equals/3
      8 ->
        [test1, test2] = get_values(codes, Enum.slice(codes, ptr + 1, 2), modes, relative_base)

        store_target =
          Enum.at(codes, ptr + 3) + if(Enum.at(modes, 2, 0) == 2, do: relative_base, else: 0)

        codes = store_value_at(codes, store_target, if(test1 == test2, do: 1, else: 0))
        interpret(ptr + 4, codes, inputs, outputs_or_pid, relative_base)

      # adjust relative base/1
      9 ->
        [relative_base_adjustment] =
          get_values(codes, Enum.slice(codes, ptr + 1, 1), modes, relative_base)

        interpret(
          ptr + 2,
          codes,
          inputs,
          outputs_or_pid,
          relative_base + relative_base_adjustment
        )

      # halt/0
      99 ->
        {nil, codes, outputs_or_pid}
    end
  end
end
