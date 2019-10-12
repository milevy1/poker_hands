defmodule PokerHands do
  @value_map %{"2" => 2,
               "3" => 3,
               "4" => 4,
               "5" => 5,
               "6" => 6,
               "7" => 7,
               "8" => 8,
               "9" => 9,
               "T" => 10,
               "J" => 11,
               "Q" => 12,
               "K" => 13,
               "A" => 14}

  def count_player_1_wins(filename) do
    File.stream!(filename)
    |> Enum.count(fn line -> String.trim(line) |> winner?() == :p1 end)
  end

  def winner?(cards_string) do
    p1_cards = cards(cards_string, :p1)
    p2_cards = cards(cards_string, :p2)

    {p1_ranking, p1_values} = ranking(p1_cards)
    {p2_ranking, p2_values} = ranking(p2_cards)

    cond do
      p1_ranking < p2_ranking -> :p1
      p1_ranking > p2_ranking -> :p2
      p1_ranking == 3 -> four_of_a_kind_tie_breaker(p1_values, p2_values)
      p1_ranking == 2 || p1_ranking == 6 -> straight_tie_breaker(p1_values, p2_values)
      p1_ranking == 4 -> full_house_tie_breaker(p1_values, p2_values)
      p1_ranking == 7 -> three_of_a_kind_tie_breaker(p1_values, p2_values)
      p1_ranking == 8 -> two_pairs_tie_breaker(p1_values, p2_values)
      p1_ranking == 9 -> one_pair_tie_breaker(p1_values, p2_values)
      p1_ranking == 10 -> high_card_assessment(p1_values, p2_values)
    end
  end

  def cards(cards_string, :p1) do
    String.split(cards_string, " ") |> Enum.take(5)
  end

  def cards(cards_string, :p2) do
    String.split(cards_string, " ") |> Enum.take(-5)
  end

  def ranking(cards) do
    values = values(cards)
    suites = suites(cards)

    cond do
      royal_flush?(values, suites) -> {1, values}
      straight_flush?(values, suites) -> {2, values}
      four_of_a_kind?(values) -> {3, values}
      full_house?(values) -> {4, values}
      flush?(suites) -> {5, values}
      straight?(values) -> {6, values}
      three_of_a_kind?(values) -> {7, values}
      two_pairs?(values) -> {8, values}
      one_pair?(values) -> {9, values}
      true -> {10, values} # high card
    end
  end

  def values(cards) do
    Enum.map(cards, fn card ->
      @value_map[String.first(card)]
    end)
    |> Enum.sort
    |> Enum.reverse
  end

  def suites(cards) do
    Enum.map(cards, &(String.last/1))
  end

  def find_sets(values) do
    Enum.chunk_by(values, &(&1))
    |> Enum.sort(fn a, b -> length(a) <= length(b) end)
    |> List.flatten
  end

  def royal_flush?([14, 13, 12, 11, 10], suites) do
    cond do
      flush?(suites) -> true
      true -> false
    end
  end
  def royal_flush?(_values, _suites), do: false

  def flush?([same_suite, same_suite, same_suite, same_suite, same_suite]), do: true
  def flush?(_suites), do: false

  def straight?([14, 5, 4, 3, 2]), do: true # Ace low straight
  def straight?([value_1, value_2, value_3, value_4, value_5])
  when value_1 == value_2 + 1 and value_2 == value_3 + 1 and value_3 == value_4 + 1 and value_4 == value_5 + 1 do
    true
  end
  def straight?(_values), do: false

  def straight_flush?(values, suites) do
    case {straight?(values), flush?(suites)} do
      {true, true} -> true
      _ -> false
    end
  end

  def straight_tie_breaker(p1_values, p2_values) when p1_values == p2_values, do: :tie
  def straight_tie_breaker(p1_values, p2_values) do
    high_card_assessment(p1_values, p2_values)
  end

  def four_of_a_kind?([value, value, value, value, _value_5]) do
    true
  end
  def four_of_a_kind?([_value_1, value, value, value, value]) do
    true
  end
  def four_of_a_kind?(_values), do: false

  def four_of_a_kind_tie_breaker(p1_values, p2_values) do
    [p1_high_card, p1_four_value | _] = find_sets(p1_values)
    [p2_high_card, p2_four_value | _] = find_sets(p2_values)

    four_of_a_kind_tie_breaker_assessment(p1_four_value, p1_high_card, p2_four_value, p2_high_card)
  end

  def four_of_a_kind_tie_breaker_assessment(p1_four_value, p1_high_card, p2_four_value, p2_high_card) do
    cond do
      p1_four_value > p2_four_value -> :p1
      p1_four_value < p2_four_value -> :p2
      true -> high_card_assessment([p1_high_card], [p2_high_card])
    end
  end

  # Because .values/1 sorts the values, the set of three and pair will
  # always be at the end or beginning of list
  def full_house?([three_value, three_value, three_value, pair_value, pair_value]) do
    true
  end

  def full_house?([pair_value, pair_value, three_value, three_value, three_value]) do
    true
  end

  def full_house?(_values), do: false

  def full_house_tie_breaker(p1_values, p2_values) do
    [p1_pair_value, _, p1_set_of_three_value, _, _] = find_sets(p1_values)
    [p2_pair_value, _, p2_set_of_three_value, _, _] = find_sets(p2_values)

    full_house_tie_breaker_assessment(p1_set_of_three_value, p1_pair_value, p2_set_of_three_value, p2_pair_value)
  end

  def full_house_tie_breaker_assessment(p1_set_of_three_value, p1_pair_value, p2_set_of_three_value, p2_pair_value) do
    cond do
      p1_set_of_three_value > p2_set_of_three_value -> :p1
      p1_set_of_three_value < p2_set_of_three_value -> :p2
      p1_pair_value > p2_pair_value -> :p1
      p1_pair_value < p2_pair_value -> :p2
      true -> :tie
    end
  end

  # Because .values/1 sorts the values,
  # the set of three can be at beginning, middle, or end of list
  def three_of_a_kind?([same_value, same_value, same_value, _, _]) do
    true
  end

  def three_of_a_kind?([_, _, same_value, same_value, same_value]) do
    true
  end

  def three_of_a_kind?([_, same_value, same_value, same_value, _]) do
    true
  end

  def three_of_a_kind?(_values), do: false

  def three_of_a_kind_tie_breaker(p1_values, p2_values) do
    [p1_kicker_1, p1_kicker_2, p1_three_value, _, _] = find_sets(p1_values)
    p1_kickers = Enum.sort([p1_kicker_1, p1_kicker_2]) |> Enum.reverse

    [p2_kicker_1, p2_kicker_2, p2_three_value, _, _] = find_sets(p2_values)
    p2_kickers = Enum.sort([p2_kicker_1, p2_kicker_2]) |> Enum.reverse

    three_of_a_kind_tie_breaker_assessment(p1_three_value, p1_kickers, p2_three_value, p2_kickers)
  end

  def three_of_a_kind_tie_breaker_assessment(p1_set_of_three_value, p1_other_values,
    p2_set_of_three_value, p2_other_values) do

    cond do
      p1_set_of_three_value > p2_set_of_three_value -> :p1
      p1_set_of_three_value < p2_set_of_three_value -> :p2
      true -> high_card_assessment(p1_other_values, p2_other_values)
    end
  end

  def two_pairs?([pair_1, pair_1, pair_2, pair_2, _value_5]) do
    true
  end

  def two_pairs?([_value_1, pair_1, pair_1, pair_2, pair_2]) do
      true
  end

  def two_pairs?([pair_1, pair_1, _value_3, pair_2, pair_2]) do
      true
  end

  def two_pairs?(_values), do: false

  def two_pairs_tie_breaker(p1_values, p2_values) do
    {p1_pairs, p1_kicker} = find_two_pairs(p1_values)
    {p2_pairs, p2_kicker} = find_two_pairs(p2_values)

    p1_high_pair = Enum.max_by(p1_pairs, fn value -> value end)
    p2_high_pair = Enum.max_by(p2_pairs, fn value -> value end)
    p1_low_pair = Enum.min_by(p1_pairs, fn value -> value end)
    p2_low_pair = Enum.min_by(p2_pairs, fn value -> value end)

    cond do
      p1_high_pair > p2_high_pair -> :p1
      p1_high_pair < p2_high_pair -> :p2
      p1_low_pair > p2_low_pair -> :p1
      p1_low_pair < p2_low_pair -> :p2
      p1_kicker > p2_kicker -> :p1
      p1_kicker < p2_kicker -> :p2
      true -> :tie
    end
  end

  # Kicker at end of list
  def find_two_pairs(p1_values) do
    [kicker, pair_1, pair_1, pair_2, pair_2] = find_sets(p1_values)

    {[pair_1, pair_2], kicker}
  end

  def one_pair?([paired_value, paired_value, _value_3, _value_4, _value_5]) do
    true
  end

  def one_pair?([_value_1, paired_value, paired_value, _value_4, _value_5]) do
    true
  end

  def one_pair?([_value_1, _value_2, paired_value, paired_value, _value_5]) do
    true
  end

  def one_pair?([_value_1, _value_2, _value_3, paired_value, paired_value]) do
    true
  end

  def one_pair?(_values), do: false

  def one_pair_tie_breaker(p1_values, p2_values) do
    {p1_pair_value, p1_kickers} = find_one_pair(p1_values)
    {p2_pair_value, p2_kickers} = find_one_pair(p2_values)

    cond do
      p1_pair_value > p2_pair_value -> :p1
      p1_pair_value < p2_pair_value -> :p2
      true -> high_card_assessment(p1_kickers, p2_kickers)
    end
  end

  def find_one_pair(values) do
    [kicker_1, kicker_2, kicker_3, paired_value, paired_value] = find_sets(values)
    kickers = [kicker_1, kicker_2, kicker_3]

    {paired_value, kickers}
  end

  def high_card_assessment([], []), do: :tie
  def high_card_assessment([p1_high_value | p1_other_values], [p2_high_value | p2_other_values]) do
    cond do
      p1_high_value > p2_high_value -> :p1
      p1_high_value < p2_high_value -> :p2
      true -> high_card_assessment(p1_other_values, p2_other_values)
    end
  end
end
