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
      # three_of_a_kind?(values) -> {7, values}
      # two_pairs -> {8, values}
      # one_pair -> {9, values}
      true -> {10, values} # high card
    end
  end

  def values(cards) do
    Enum.map(cards, &(String.first/1))
    |> Enum.sort
  end

  def suites(cards) do
    Enum.map(cards, &(String.last/1))
  end

  def royal_flush?(["A", "J", "K", "Q", "T"], suites) do
    cond do
      flush?(suites) -> true
      true -> false
    end
  end
  def royal_flush?(_values, _suites), do: false

  def flush?(["C", "C", "C", "C", "C"]), do: true
  def flush?(["D", "D", "D", "D", "D"]), do: true
  def flush?(["S", "S", "S", "S", "S"]), do: true
  def flush?(["H", "H", "H", "H", "H"]), do: true
  def flush?(_suites), do: false

  def straight?(["2", "3", "4", "5", "A"]), do: true
  def straight?(["2", "3", "4", "5", "6"]), do: true
  def straight?(["3", "4", "5", "6", "7"]), do: true
  def straight?(["4", "5", "6", "7", "8"]), do: true
  def straight?(["5", "6", "7", "8", "9"]), do: true
  def straight?(["6", "7", "8", "9", "T"]), do: true
  def straight?(["7", "8", "9", "J", "T"]), do: true
  def straight?(["8", "9", "J", "Q", "T"]), do: true
  def straight?(["9", "J", "K", "Q", "T"]), do: true
  def straight?(["A", "J", "K", "Q", "T"]), do: true
  def straight?(_values), do: false

  def straight_flush?(values, suites) do
    case {straight?(values), flush?(suites)} do
      {true, true} -> true
      _ -> false
    end
  end

  def straight_tie_breaker(p1_values, p2_values) when p1_values == p2_values, do: :tie
  def straight_tie_breaker(["A", "J", "K", "Q", "T"], _p2_values), do: :p1
  def straight_tie_breaker(_p1_values, ["A", "J", "K", "Q", "T"]), do: :p2
  def straight_tie_breaker(["9", "J", "K", "Q", "T"], _p2_values), do: :p1
  def straight_tie_breaker(_p1_values, ["9", "J", "K", "Q", "T"]), do: :p2
  def straight_tie_breaker(["8", "9", "J", "Q", "T"], _p2_values), do: :p1
  def straight_tie_breaker(_p1_values, ["8", "9", "J", "Q", "T"]), do: :p2
  def straight_tie_breaker(["7", "8", "9", "J", "T"], _p2_values), do: :p1
  def straight_tie_breaker(_p1_values, ["7", "8", "9", "J", "T"]), do: :p2
  def straight_tie_breaker(["6", "7", "8", "9", "T"], _p2_values), do: :p1
  def straight_tie_breaker(_p1_values, ["6", "7", "8", "9", "T"]), do: :p2
  def straight_tie_breaker(["5", "6", "7", "8", "9"], _p2_values), do: :p1
  def straight_tie_breaker(_p1_values, ["5", "6", "7", "8", "9"]), do: :p2
  def straight_tie_breaker(["4", "5", "6", "7", "8"], _p2_values), do: :p1
  def straight_tie_breaker(_p1_values, ["4", "5", "6", "7", "8"]), do: :p2
  def straight_tie_breaker(["3", "4", "5", "6", "7"], _p2_values), do: :p1
  def straight_tie_breaker(_p1_values, ["3", "4", "5", "6", "7"]), do: :p2
  def straight_tie_breaker(["2", "3", "4", "5", "6"], _p2_values), do: :p1
  def straight_tie_breaker(_p1_values, ["2", "3", "4", "5", "6"]), do: :p2
  def straight_tie_breaker(["2", "3", "4", "5", "A"], _p2_values), do: :p1
  def straight_tie_breaker(_p1_values, ["2", "3", "4", "5", "A"]), do: :p2

  def four_of_a_kind?([value_1, value_2, value_3, value_4, _value_5])
    when value_1 == value_2 and value_1 == value_3 and value_1 == value_4 do
    true
  end
  def four_of_a_kind?([_value_1, value_2, value_3, value_4, value_5])
    when value_2 == value_3 and value_2 == value_4 and value_2 == value_5 do
    true
  end
  def four_of_a_kind?(_values), do: false

  # Because values are sorted by .values/1, set of fours
  # will be in beginning or end of list
  def four_of_a_kind_tie_breaker([p1_value_1, p1_value_2, _p1_value_3, _p1_value_4, p1_high_card],
    [p2_value_1, p2_value_2, _p2_value_3, _p2_value_4, p2_high_card])
      when p1_value_1 == p1_value_2 and p2_value_1 == p2_value_2 do

      four_of_a_kind_tie_breaker_assessment(p1_value_1, p1_high_card, p2_value_1, p2_high_card)
  end

  def four_of_a_kind_tie_breaker([p1_high_card, _p1_value_2, _p1_value_3, p1_value_4, p1_value_5],
    [p2_value_1, p2_value_2, _p2_value_3, _p2_value_4, p2_high_card])
      when p1_value_4 == p1_value_5 and p2_value_1 == p2_value_2 do

      four_of_a_kind_tie_breaker_assessment(p1_value_5, p1_high_card, p2_value_1, p2_high_card)
  end

  def four_of_a_kind_tie_breaker([p1_value_1, p1_value_2, _p1_value_3, _p1_value_4, p1_high_card],
    [p2_high_card, _p2_value_2, _p2_value_3, p2_value_4, p2_value_5])
      when p1_value_1 == p1_value_2 and p2_value_4 == p2_value_5 do

      four_of_a_kind_tie_breaker_assessment(p1_value_1, p1_high_card, p2_value_5, p2_high_card)
  end

  def four_of_a_kind_tie_breaker([p1_high_card, _p1_value_2, _p1_value_3, p1_value_4, p1_value_5],
    [p2_high_card, _p2_value_2, _p2_value_3, p2_value_4, p2_value_5])
      when p1_value_4 == p1_value_5 and p2_value_4 == p2_value_5 do

      four_of_a_kind_tie_breaker_assessment(p1_value_5, p1_high_card, p2_value_5, p2_high_card)
  end

  def four_of_a_kind_tie_breaker_assessment(p1_four_value, p1_high_card, p2_four_value, p2_high_card) do
    cond do
      @value_map[p1_four_value] > @value_map[p2_four_value] -> :p1
      @value_map[p1_four_value] < @value_map[p2_four_value] -> :p2
      @value_map[p1_high_card] > @value_map[p2_high_card] -> :p1
      @value_map[p1_high_card] < @value_map[p2_high_card] -> :p2
      true -> :tie
    end
  end

  # Because .values/1 sorts the values, the set of three and pair will
  # always be at the end or beginning of list
  def full_house?([value_1, value_2, value_3, value_4, value_5])
    when value_1 == value_2 and value_2 == value_3 and value_4 == value_5 do
      true
  end

  def full_house?([value_1, value_2, value_3, value_4, value_5])
    when value_1 == value_2 and value_3 == value_4 and value_4 == value_5 do
      true
  end

  def full_house?(_values), do: false

  # Both sets of 3 in beginning of list
  def full_house_tie_breaker([p1_value_1, p1_value_2, p1_value_3, p1_value_4, p1_value_5],
    [p2_value_1, p2_value_2, p2_value_3, p2_value_4, p2_value_5])
    when p1_value_1 == p1_value_2 and p1_value_2 == p1_value_3 and p1_value_4 == p1_value_5
     and p2_value_1 == p2_value_2 and p2_value_2 == p2_value_3 and p2_value_4 == p2_value_5 do

       full_house_tie_breaker_assessment(p1_value_1, p1_value_5, p2_value_1, p2_value_5)
  end

  # Both sets of 3 at end of list
  def full_house_tie_breaker([p1_value_1, p1_value_2, p1_value_3, p1_value_4, p1_value_5],
    [p2_value_1, p2_value_2, p2_value_3, p2_value_4, p2_value_5])
    when p1_value_1 == p1_value_2 and p1_value_3 == p1_value_4 and p1_value_4 == p1_value_5
     and p2_value_1 == p2_value_2 and p2_value_3 == p2_value_4 and p2_value_4 == p2_value_5 do

       full_house_tie_breaker_assessment(p1_value_5, p1_value_1, p2_value_5, p2_value_1)
  end

  # Player 1 set of 3 at end of list,
  # Player 2 set of 3 at beginning of list
  def full_house_tie_breaker([p1_value_1, p1_value_2, p1_value_3, p1_value_4, p1_value_5],
    [p2_value_1, p2_value_2, p2_value_3, p2_value_4, p2_value_5])
    when p1_value_1 == p1_value_2 and p1_value_3 == p1_value_4 and p1_value_4 == p1_value_5
     and p2_value_1 == p2_value_2 and p2_value_1 == p2_value_3 and p2_value_4 == p2_value_5 do

       full_house_tie_breaker_assessment(p1_value_5, p1_value_1, p2_value_1, p2_value_5)
  end

  # Player 1 set of 3 at beginning of list,
  # Player 2 set of 3 at end of list
  def full_house_tie_breaker([p1_value_1, p1_value_2, p1_value_3, p1_value_4, p1_value_5],
    [p2_value_1, p2_value_2, p2_value_3, p2_value_4, p2_value_5])
    when p1_value_1 == p1_value_2 and p1_value_1 == p1_value_3 and p1_value_4 == p1_value_5
     and p2_value_1 == p2_value_2 and p2_value_3 == p2_value_4 and p2_value_4 == p2_value_5 do

       full_house_tie_breaker_assessment(p1_value_1, p1_value_5, p2_value_5, p2_value_1)
  end

  def full_house_tie_breaker_assessment(p1_set_of_three_value, p1_pair_value, p2_set_of_three_value, p2_pair_value) do
    cond do
      @value_map[p1_set_of_three_value] > @value_map[p2_set_of_three_value] -> :p1
      @value_map[p1_set_of_three_value] < @value_map[p2_set_of_three_value] -> :p2
      @value_map[p1_pair_value] > @value_map[p2_pair_value] -> :p1
      @value_map[p1_pair_value] < @value_map[p2_pair_value] -> :p2
      true -> :tie
    end
  end
end
