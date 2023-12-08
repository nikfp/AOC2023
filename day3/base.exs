test_file =
  File.read!("./test.txt")

prod_file =
  File.read!("./prod.txt")

defmodule AOC do
  def normalize(x) do
    case x do
      x when x >= "0" and x <= "9" -> x
      "." -> x
      "*" -> x
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
    |> Stream.drop(skip)
    |> Stream.take(number_length)
    |> Stream.map(fn {x, _, _} -> x end)
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
      {x + 1, y + 1},
      {x, y}
    ]
    |> Stream.filter(fn {x, _} ->
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
    {start, y} = a
    {last, _} = b

    start..last
    |> Stream.map(fn x -> {x, y} end)
    |> Enum.map(fn x -> find_surrounding(x, size) end)
    |> List.flatten()
    |> Enum.uniq()
  end

  def is_symbol?({x, y}, puzzle) do
    {_, line} = Enum.fetch(puzzle, y)
    {_, char_data} = Enum.fetch(line, x)
    {char, _, _} = char_data

    case char do
      "S" -> true
      "*" -> true
      _ -> false
    end
  end

  def split_puzzle(input) do
    input
    |> String.split()
    |> Stream.map(fn line ->
      String.split(line, "", trim: true)
    end)
    |> Stream.with_index()
    |> Stream.map(fn {line, y} ->
      Stream.with_index(line)
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
  end

  def is_digit?({sur_x, sur_y}, locs) do
    Enum.filter(locs, fn loc ->
      case loc do
        {{first, vert}, {last, _}}
        when first <= sur_x and
               last >= sur_x and
               vert == sur_y ->
          true

        _ ->
          false
      end
    end)
  end

  def get_adjacent_numbers({_, x, y}, puzzle_size, locations) do
    AOC.find_surrounding({x, y}, puzzle_size)
    |> Stream.map(fn sur ->
      AOC.is_digit?(sur, locations)
    end)
    |> Stream.concat()
    |> Enum.uniq()
  end
end

defmodule NumFinder do
  # this is the tricky bit. Note the recursive function
  # This will process a horizontal line and find numbers
  # Accum. shape is: {start_or_nil, list_of_found, current_x_index}
  # start_or_nil will be either nil or {x, y} as a position

  def line_search([char | tail], acc) do
    # get some values I need from the character
    {value, x, y} = char
    # Get either nil or the starting position
    {tracking, _, _} = acc

    case acc do
      {nil, list, pos} ->
        cond do
          # if acc is nil and input is a number, start tracking
          AOC.is_integer?(value) ->
            line_search(tail, {{x, y}, list, pos + 1})

          # if acc is nil and input is a not a number, continue
          true ->
            line_search(tail, {nil, list, pos + 1})
        end

      {_, list, pos} ->
        cond do
          # if acc is tracking and input is a number, pass it through
          AOC.is_integer?(value) ->
            line_search(tail, {tracking, list, pos + 1})

          # if acc is tracking and input is not a number, finish and
          # push to end of list
          true ->
            line_search(tail, {nil, list ++ [{tracking, {pos - 1, y}}], pos + 1})
        end
    end
  end

  # This is the base case, note it takes an empty list
  def line_search([], acc) do
    # if accumulator is tracking, finish tracking and return accum
    case acc do
      {{x, y}, list, pos} ->
        {nil, list ++ [{{x, y}, {pos - 1, y}}], 0}

      # if not, just return accum
      _ ->
        acc
    end
  end

  def parse_numbers(lines) do
    lines
    |> Stream.map(fn x -> NumFinder.line_search(x, {nil, [], 0}) end)
    |> Stream.map(&elem(&1, 1))
    |> Enum.concat()
  end
end

solver_1 = fn input ->
  lines = AOC.split_puzzle(input)

  puzzle_size = length(lines)

  # this parses out locations for numbers
  locations = NumFinder.parse_numbers(lines)

  locations
  |> Stream.filter(fn {a, b} ->
    AOC.find_all_surrounding({a, b}, puzzle_size)
    |> Enum.any?(fn x -> AOC.is_symbol?(x, lines) end)
  end)
  |> Stream.map(fn x -> AOC.extract_number(x, lines) end)
  |> Enum.sum()
end

test_file |> solver_1.() |> IO.inspect()
prod_file |> solver_1.() |> IO.inspect()

solver_2 = fn input ->
  lines = AOC.split_puzzle(input)

  puzzle_size = length(lines)

  locations = NumFinder.parse_numbers(lines)

  lines
  |> Stream.map(fn x ->
    Enum.filter(x, fn y ->
      case y do
        {char, _, _} when char == "*" -> true
        _ -> false
      end
    end)
  end)
  |> Stream.concat()
  |> Stream.map(&AOC.get_adjacent_numbers(&1, puzzle_size, locations))
  |> Stream.filter(fn x ->
    case x do
      x when length(x) == 2 -> true
      _ -> false
    end
  end)
  |> Stream.map(fn [a, b] ->
    AOC.extract_number(a, lines) * AOC.extract_number(b, lines)
  end)
  |> Enum.sum()
end

test_file |> solver_2.() |> IO.inspect()
prod_file |> solver_2.() |> IO.inspect()
