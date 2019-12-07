defmodule Day7.ThrusterTester2 do
  def run do
    "inputs/day7.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
    |> find_max_signal
  end

  @doc """
      iex> Day7.ThrusterTester2.find_max_signal([3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5])
      [139629729, [9,8,7,6,5]] # this fails (doesn't halt)
      iex> Day7.ThrusterTester2.find_max_signal([3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10])
      [18216, [9,7,8,5,6]] # same for this one

      ...yet the answer was correct for the actual input. sigh
  """
  def find_max_signal(program) do
    for a <- 5..9,
        b <- 5..9,
        c <- 5..9,
        d <- 5..9,
        e <- 5..9 do
      settings = [a, b, c, d, e]

      if Enum.uniq(settings) |> length == 5 do
        test_settings(program, settings)
      end
    end
    |> Enum.filter(& &1)
    |> Enum.max_by(&Enum.at(&1, 0))
  end

  def test_settings(
        program,
        [a, b, c, d, e],
        [ptr_a, ptr_b, ptr_c, ptr_d, ptr_e] \\ [0, 0, 0, 0, 0],
        iv \\ [0],
        iteration \\ 0
      ) do
    inputs_a = if iteration == 0, do: [a | iv], else: iv
    {ptr_a, [output_a]} = Day7.IntcodeInterpreter2.start_program(program, inputs_a, ptr_a)
    inputs_b = if iteration == 0, do: [b, output_a], else: [output_a]
    {ptr_b, [output_b]} = Day7.IntcodeInterpreter2.start_program(program, inputs_b, ptr_b)
    inputs_c = if iteration == 0, do: [c, output_b], else: [output_b]
    {ptr_c, [output_c]} = Day7.IntcodeInterpreter2.start_program(program, inputs_c, ptr_c)
    inputs_d = if iteration == 0, do: [d, output_c], else: [output_c]
    {ptr_d, [output_d]} = Day7.IntcodeInterpreter2.start_program(program, inputs_d, ptr_d)
    inputs_e = if iteration == 0, do: [e, output_d], else: [output_d]
    {ptr_e, [output_e]} = Day7.IntcodeInterpreter2.start_program(program, inputs_e, ptr_e)

    # IO.inspect(output_e)

    if is_nil(ptr_e) || iteration >= 100 do
      [output_e, [a, b, c, d, e]]
    else
      test_settings(
        program,
        [a, b, c, d, e],
        [ptr_a, ptr_b, ptr_c, ptr_d, ptr_e],
        [output_e],
        iteration + 1
      )
    end
  end
end
