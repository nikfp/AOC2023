test_file =
  File.read!("./test.txt")

_prod_file =
  File.read!("./prod.txt")

defmodule AOC do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&AOC.parse_line/1)
  end

  def parse_line(line) do
    [x, y] =
      line
      |> String.split(":")

    [left, right] = AOC.parse_scratches(y)
    {x, left, right}
  end

  def parse_scratches(input) do
    String.split(input, "|", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
  end

  def compare_winning(left, right) do
    Enum.filter(right, fn x ->
      Enum.member?(left, x)
    end)
  end
end

solver_1 = fn x ->
  AOC.parse_input(x)
  |> Enum.map(fn {_, left, right} -> 
    AOC.compare_winning(left, right)
  end)
end

test_file |> solver_1.() |> IO.inspect()
