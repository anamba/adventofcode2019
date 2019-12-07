defmodule Day7.ThrusterTester do
  def run do
    "inputs/day7.txt"
    |> File.stream!()
    |> Enum.map(fn line ->
      line |> String.trim() |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> List.flatten()
    |> test_signal
  end

  @doc """
      iex> Day7.ThrusterTester.test_signal([3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0])
      [43210, 4,3,2,1,0]
      iex> Day7.ThrusterTester.test_signal([3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0])
      [54321, 0,1,2,3,4]
      iex> Day7.ThrusterTester.test_signal([3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0])
      [65210, 0,1,2,3,4] # fails... hmm
  """
  def test_signal(program) do
    for a <- 0..4,
        b <- 0..4,
        c <- 0..4,
        d <- 0..4,
        e <- 0..4 do
      if Enum.uniq([a, b, c, d, e]) |> length == 5 do
        with {_, [output_a]} <- Day7.IntcodeInterpreter.start_program(program, [a, 0]),
             {_, [output_b]} <- Day7.IntcodeInterpreter.start_program(program, [b, output_a]),
             {_, [output_c]} <- Day7.IntcodeInterpreter.start_program(program, [c, output_b]),
             {_, [output_d]} <- Day7.IntcodeInterpreter.start_program(program, [d, output_c]),
             {_, [output_e]} <- Day7.IntcodeInterpreter.start_program(program, [e, output_d]) do
          [output_e, a, b, c, d, e]
        end
      end
    end
    |> Enum.filter(& &1)
    |> Enum.max_by(&Enum.at(&1, 0))
  end
end
