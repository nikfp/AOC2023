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

    {AOC.parse_card_number(x), left, right}
  end

  def parse_scratches(input) do
    String.split(input, "|", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
  end

  def parse_card_number(card) do
    [_, number] = String.split(card)

    String.to_integer(number)
  end

  def compare_winning(left, right) do
    Enum.filter(right, fn x ->
      Enum.member?(left, x)
    end)
  end

  def part_2_process([head | tail], count, list) do
    {card, wins} = head
    #
    adds = list |> Enum.drop(card) |> Enum.take(wins)
    #
    values = tail ++ adds

    part_2_process(values, count + 1, list)
  end

  def part_2_process([], count, _) do
    count
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

_solver_1 = fn x ->
  AOC.parse_input(x)
  |> Enum.map(fn {_, left, right} ->
    AOC.compare_winning(left, right)
  end)
  |> Enum.map(&Part1_score.score_card/1)
  |> Enum.sum()
end

# test_file |> solver_1.() |> IO.inspect()
# prod_file |> solver_1.() |> IO.inspect()

solver_2 = fn x ->
  list =
    AOC.parse_input(x)
    |> Enum.map(fn {card, left, right} ->
      {card, AOC.compare_winning(left, right)}
    end)
    |> Enum.map(fn {card, list} -> {card, length(list)} end)
    |> Enum.reverse()
    |> Enum.reduce(%{}, fn {pos, list_count}, acc ->
      case list_count do
        0 ->
          Map.put(acc, pos, list_count + 1)

        _ ->
          map_data =
            (pos + 1)..(pos + list_count)
            |> Enum.reduce(0, fn key, count_acc ->
              count_acc + Map.fetch!(acc, key)
            end)

          Map.put(acc, pos, map_data + 1)
      end
    end)
    |> Enum.map(fn {x, y} -> y end)
    |> Enum.sum()

  # accum_list = 
  #   AOC.parse_input(x)
  #   |> Enum.map(fn {card, left, right} ->
  #     {card, AOC.compare_winning(left, right)}
  #   end)
  #   |> Enum.map(fn {card, list} -> {card, length(list)} end)
  #
  #
  # AOC.part_2_process(accum_list, 0, list)
end

test_file
|> solver_2.()
|> IO.inspect()

prod_file
|> solver_2.()
|> IO.inspect()
