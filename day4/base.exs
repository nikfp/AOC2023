test_file =
  File.read!("./test.txt")

prod_file =
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

defmodule Part1_score do
  def score_card([_head | tail]) do
    tail_length = length(tail)

    case tail_length do
      0 -> 1
      _ -> 1 * 2 ** tail_length
    end
  end

  def score_card([]) do
    0
  end
end

solver_1 = fn x ->
  AOC.parse_input(x)
  |> Enum.map(fn {_, left, right} ->
    AOC.compare_winning(left, right)
  end)
  |> Enum.map(&Part1_score.score_card/1)
  |> Enum.sum()
end

test_file |> solver_1.() |> IO.inspect()
prod_file |> solver_1.() |> IO.inspect()
