defmodule Day7.ThrusterTester2a do
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
      iex> Day7.ThrusterTester2a.find_max_signal([3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5])
      [139629729, [9,8,7,6,5]]
      iex> Day7.ThrusterTester2a.find_max_signal([3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10])
      [18216, [9,7,8,5,6]]
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

  def test_settings(program, [a, b, c, d, e]) do
    pid_e = spawn(Day7.IntcodeInterpreter2a, :start_program, [program, [e], self()])
    pid_d = spawn(Day7.IntcodeInterpreter2a, :start_program, [program, [d], pid_e])
    pid_c = spawn(Day7.IntcodeInterpreter2a, :start_program, [program, [c], pid_d])
    pid_b = spawn(Day7.IntcodeInterpreter2a, :start_program, [program, [b], pid_c])
    pid_a = spawn(Day7.IntcodeInterpreter2a, :start_program, [program, [a, 0], pid_b])

    run_until_finished(pid_a, [a, b, c, d, e])
  end

  def run_until_finished(pid, [a, b, c, d, e]) do
    receive do
      output ->
        if Process.alive?(pid) do
          send(pid, output)
          run_until_finished(pid, [a, b, c, d, e])
        else
          [output, [a, b, c, d, e]]
        end
    end
  end
end
