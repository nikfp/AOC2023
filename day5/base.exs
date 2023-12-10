test_file =
  File.read!("./test.txt")

defmodule AOC do
  def parse_input(input) do
    [seeds | maps] = String.split(input, "\n\n")
    maps
  end
end

solver_1 = fn x ->
  x
  |> AOC.parse_input()
end

test_file
|> solver_1.()
|> IO.inspect()
