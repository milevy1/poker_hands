defmodule PokerHands do
  def winner?(cards_string) do
    p1_cards = cards(cards_string, :p1)
    p2_cards = cards(cards_string, :p2)

    {p1_ranking, p1_values} = ranking(p1_cards)
    {p2_ranking, p2_values} = ranking(p2_cards)

    cond do
      p1_ranking < p2_ranking -> :p1
      p1_ranking > p2_ranking -> :p2
      p1_ranking == 6 || p1_ranking == 2 -> straight_high_card_winner?(p1_values, p2_values)
    end
  end

  def straight_high_card_winner?(p1_values, p2_values) when p1_values == p2_values, do: :tie
  def straight_high_card_winner?(["A", "J", "K", "Q", "T"], _p2_values), do: :p1
  def straight_high_card_winner?(_p1_values, ["A", "J", "K", "Q", "T"]), do: :p2
  def straight_high_card_winner?(["9", "J", "K", "Q", "T"], _p2_values), do: :p1
  def straight_high_card_winner?(_p1_values, ["9", "J", "K", "Q", "T"]), do: :p2
  def straight_high_card_winner?(["8", "9", "J", "Q", "T"], _p2_values), do: :p1
  def straight_high_card_winner?(_p1_values, ["8", "9", "J", "Q", "T"]), do: :p2
  def straight_high_card_winner?(["7", "8", "9", "J", "T"], _p2_values), do: :p1
  def straight_high_card_winner?(_p1_values, ["7", "8", "9", "J", "T"]), do: :p2
  def straight_high_card_winner?(["6", "7", "8", "9", "T"], _p2_values), do: :p1
  def straight_high_card_winner?(_p1_values, ["6", "7", "8", "9", "T"]), do: :p2
  def straight_high_card_winner?(["5", "6", "7", "8", "9"], _p2_values), do: :p1
  def straight_high_card_winner?(_p1_values, ["5", "6", "7", "8", "9"]), do: :p2
  def straight_high_card_winner?(["4", "5", "6", "7", "8"], _p2_values), do: :p1
  def straight_high_card_winner?(_p1_values, ["4", "5", "6", "7", "8"]), do: :p2
  def straight_high_card_winner?(["3", "4", "5", "6", "7"], _p2_values), do: :p1
  def straight_high_card_winner?(_p1_values, ["3", "4", "5", "6", "7"]), do: :p2
  def straight_high_card_winner?(["2", "3", "4", "5", "6"], _p2_values), do: :p1
  def straight_high_card_winner?(_p1_values, ["2", "3", "4", "5", "6"]), do: :p2
  def straight_high_card_winner?(["2", "3", "4", "5", "A"], _p2_values), do: :p1
  def straight_high_card_winner?(_p1_values, ["2", "3", "4", "5", "A"]), do: :p2

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
      # four_of_a_kind?(values) -> {3, values}
      # full_house?(values) -> {4, values}
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
end
