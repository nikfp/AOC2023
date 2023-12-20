test_file =
  File.read!("./test.txt")

prod_file =
  File.read!("./prod.txt")

defmodule AOC do
  def parse_input(input) do
    [seeds | maps] = String.split(input, "\n\n")
    [_ | seed_strings] = seeds |> String.split(" ")
    seed_values = seed_strings |> Enum.map(&String.to_integer/1)

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

defmodule InputSplitter do
  # input lb and ub is lower than test 
  def evaluate({{in_l, in_h}, {test_l, _}}) when in_h < test_l do
    {{in_l, in_h}, :ok}
  end

  # input range above test
  def evaluate({{in_l, in_h}, {_, test_h}})
      when in_l >= test_h do
    {{in_l, in_h}, :advance}
  end

  # input lb is below test, ub is within test -> split
  def evaluate({{in_l, in_h}, {test_l, _}})
      when in_l < test_l and in_h >= test_l do
    {{in_l, test_l - 1}, {test_l, in_h}}
  end

  # input lb within test, input ub within test
  def evaluate({{in_l, in_h}, {test_l, test_h}})
      when in_l >= test_l and
             in_h <= test_h do
    {{in_l, in_h}, :ok}
  end

  # input lb within test, input ub outside test
  def evaluate({{in_l, in_h}, {test_l, test_h}})
      when in_l >= test_l and
             in_h > test_h do
    {{in_l, test_h}, {test_h + 1, in_h}}
  end

  def process(input, tester_list, acc) do
    case tester_list do
      [] ->
        acc ++ [input]

      _ ->
        case evaluate({input, hd(tester_list)}) do
          {value, :ok} ->
            acc ++ [value]

          {value, :advance} ->
            process(value, tl(tester_list), acc)

          {value, next_range} ->
            process(next_range, tester_list, acc ++ [value])
        end
    end
  end

  def process(input, [], acc) do
    acc
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

  
  #
  ranges =
    inputs
    |> Enum.chunk_every(2)
    |> Enum.map(fn [a, b] -> {a, a + b - 1} end)

  mapper_settings
  |> Enum.reduce(ranges, fn mapper, acc ->
    transformer = AOC.build_transformer(mapper)
    comp_list = AOC.build_comparison_list(mapper)

    # IO.puts(" ")
    # IO.inspect(acc, label: "range input")
    # IO.inspect(comp_list, label: "compare list")
    
    acc
    |> Enum.map(fn x ->
      InputSplitter.process(x, comp_list, [])
    end)
    |> List.flatten()
    |> Enum.map(fn {low, high} -> 
    {transformer.(low), transformer.(high)}
    end)
  end)
  |> Enum.map(fn {x, _} -> x end)
  |> Enum.min()
end

test_file
|> solver_2.()
|> IO.inspect(label: "Test Case")

prod_file
|> solver_2.()
|> IO.inspect(label: "Prod Case")
# {{50, 98}, {50, 97}}
# |> InputSplitter.evaluate()
# |> IO.inspect()

# test_file
# |> solver_1.()
# |> IO.inspect()

# prod_file
# |> solver_1.()
# |> IO.inspect()

# {{48, 101}, [{50, 94}, {98, 99}]}
# |> IO.inspect(label: "base")
# |> (fn {input, tester_list} ->
#       InputSplitter.process(input, tester_list, [])
#     end).()
# |> IO.inspect()
