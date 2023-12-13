test_file =
  File.read!("./test.txt")

prod_file =
  File.read!("./prod.txt")

defmodule AOC do
  def parse_input(input) do
    [seeds | maps] = String.split(input, "\n\n")
    [_ | seed_strings] = seeds |> String.split(" ")
    seed_values = seed_strings |> Enum.map(&String.to_integer/1)
    maps

    map_values =
      maps
      |> Enum.map(fn group ->
        [_ | map_strings] =
          group
          |> String.split("\n", trim: true)
          |> Enum.map(fn map_string ->
            String.split(map_string, " ", trim: true)
            # |> Enum.map(&String.to_integer/1)
          end)

        map_strings
        |> Enum.map(fn x ->
          [dest, start, offset] = Enum.map(x, fn y -> String.to_integer(y) end)
          {dest, start, offset}
        end)
        |> Enum.sort(fn {_, x, _}, {_, y, _} -> x <= y end)
      end)

    {seed_values, map_values}
  end

  def build_offsetter({dest, start, offset}) do
    # shape of offsetter input should be {:mapped, value} or {:pending, value}
    # if mapped, pass through
    # if pending, test for range fit. No match -> pass through
    # if test matches, offset and return {:mapped, value}
    fn x ->
      case x do
        {:mapped, _} ->
          x

        {:pending, val} when val >= start and val < start + offset ->
          {:mapped, val - (start - dest)}

        _ ->
          x
      end
    end
  end

  def build_transformer(mapper_list) do
    offsetters = mapper_list |> Enum.map(&AOC.build_offsetter/1)

    fn x ->
      {_, value} =
        Enum.reduce(offsetters, {:pending, x}, fn offsetter, acc ->
          # offsetter
          offsetter.(acc)
        end)

      value
    end
  end

  def build_pipeline(transformer_inputs) do
    transformers = transformer_inputs |> Enum.map(&AOC.build_transformer/1)

    fn x ->
      Enum.reduce(transformers, x, fn transformer, acc ->
        transformer.(acc)
      end)
    end
  end

  def build_comparison_list(mapper_settings) do
    mapper_settings |> Enum.map(fn {_, begin, offset} -> {begin, begin + offset - 1} end)
  end
end

# solver_1 = fn x ->
#   {inputs, mapper_settings} =
#     x
#     |> AOC.parse_input()
#
#
#   pipeline = AOC.build_pipeline(mapper_settings)
#   #
#   #
#   inputs
#   |> Enum.map(fn x -> pipeline.(x) end)
#   |> Enum.min()
# end
solver_2 = fn x ->
  {inputs, mapper_settings} =
    x
    |> AOC.parse_input()

  compare_lists =
    mapper_settings
    |> Enum.map(&AOC.build_comparison_list/1)

  first_set =
    inputs
    |> Enum.chunk_every(2)
    |> Enum.map(fn [a, b] -> {a, a + b - 1} end)
    |> hd()

  first_compare = hd(compare_lists)
  {first_set, first_compare}
end

# compare lower bound of input range to first transform lower bound
# if input range LB is lower, compare input LB to transform UB
# if it's still lower, skip to the next transformer. 


# test_file
# |> solver_1.()
# |> IO.inspect()
test_file
|> solver_2.()
|> IO.inspect()

# prod_file
# |> solver_1.()
# |> IO.inspect()
