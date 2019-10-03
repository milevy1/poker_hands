defmodule PokerHands do
  def winner?(cards_string) do
    p1_cards = cards(cards_string, :p1)
    p2_cards = cards(cards_string, :p2)

    p1_ranking = ranking(p1_cards)
    p2_ranking = ranking(p2_cards)

    cond do
      p1_ranking < p2_ranking -> :p1
      p1_ranking > p2_ranking -> :p2
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
      royal_flush?(values, suites) -> 1
      # straight_flush?(values, suites) -> 2
      # four_of_a_kind?(values) -> 3
      # full_house?(values) -> 4
      flush?(suites) -> 5
      # straight?(values) -> 6
      # three_of_a_kind?(values) -> 7
      # two_pairs -> 8
      # one_pair -> 9
      true -> 10 # high card
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
end
