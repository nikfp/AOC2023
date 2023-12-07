test_file =
  File.read!("./test.txt")

prod_file = 
  File.read!("./prod.txt")

defmodule AOC do
  def normalize(x) do
    case x do
      x when x >= "0" and x <= "9" -> x
      "." -> x
      _ -> "S"
    end
  end

  def is_integer?(x) do
    try do
      _ = String.to_integer(x)
      true
    rescue
      _ ->
        false
    end
  end

  def extract_number({{skip, y}, {last, _}}, puzzle) do
    {_, line} = puzzle |> Enum.fetch(y)
    number_length = last - skip + 1

    line
    |> Enum.drop(skip)
    |> Enum.take(number_length)
    |> Enum.map(fn {x, _, _} -> x end)
    |> Enum.join()
    |> String.to_integer()
  end

  def find_surrounding({x, y}, size) do
    [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]
    |> Enum.filter(fn {x, _} ->
      case x do
        x when x >= 0 and x < size -> true
        _ -> false
      end
    end)
    |> Enum.filter(fn {_, y} ->
      case y do
        y when y >= 0 and y < size -> true
        _ -> false
      end
    end)
  end

  def find_all_surrounding({a, b}, size) do
    (find_surrounding(a, size) ++ find_surrounding(b, size))
    |> Enum.uniq()
  end

  def is_symbol?({x, y}, puzzle) do
    {_, line} = Enum.fetch(puzzle, y)
    {_, char_data} = Enum.fetch(line, x)
    {char, _, _} = char_data

    case char do
      "S" -> true
      _ -> false
    end
  end
end

defmodule NumFinder do
  def locate(char, acc) do
    {value, x, y} = char

    {tracking, list} = acc
    prev_x = x - 1

    case acc do
      {nil, list} ->
        cond do
          # if acc is nil and input is a number, start tracking
          AOC.is_integer?(value) ->
            {{x, y}, list}

          # if acc is nil and input is a not a number, continue
          true ->
            acc
        end

      _ ->
        cond do
          # if acc is tracking and input is a number, pass it through
          AOC.is_integer?(value) ->
            acc

          # if acc is tracking and input is not a number, finish and
          true ->
            {nil, list ++ [{tracking, {prev_x, y}}]}
        end
    end
  end
end

# or if end of line is reached
# push to list of tracked locations

solver_1 = fn x ->
  lines =
    String.split(x)
    |> Enum.map(fn line ->
      String.split(line, "")
      |> Enum.filter(fn x ->
        case x do
          "" -> false
          _ -> true
        end
      end)
    end)
    |> Enum.with_index()
    |> Enum.map(fn {line, y} ->
      Enum.with_index(line)
      |> Enum.map(fn {char, x} ->
        {char, x, y}
      end)
    end)
    |> Enum.map(fn x ->
      Enum.map(x, fn {char, hor, vert} ->
        normal = AOC.normalize(char)
        {normal, hor, vert}
      end)
    end)

  puzzle_size = length(lines)

  # this parses out locations for numbers
  locations =
    lines
    |> Enum.map(fn x ->
      Enum.reduce(x, {nil, []}, &NumFinder.locate/2)
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.concat()

  locations
  |> Enum.filter(fn {a, b} ->
    AOC.find_all_surrounding({a, b}, puzzle_size)
    |> Enum.any?(fn x -> AOC.is_symbol?(x, lines) end)
    # |> IO.inspect()
  end)
  |> Enum.map(fn x -> AOC.extract_number(x, lines) end)
  |> Enum.sum()
end

test_file |> solver_1.() |> IO.inspect()
prod_file |> solver_1.() |> IO.inspect()



