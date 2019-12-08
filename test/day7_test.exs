defmodule Day7Test do
  use ExUnit.Case

  doctest Day7.IntcodeInterpreter
  doctest Day7.ThrusterTester
  doctest Day7.IntcodeInterpreter2
  doctest Day7.ThrusterTester2

  doctest Day7.IntcodeInterpreter2a
  @tag timeout: 1000
  doctest Day7.ThrusterTester2a
end
