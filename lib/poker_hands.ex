defmodule PokerHands do
  def winner?(cards_string) do
    p1_cards = String.split(cards_string, " ") |> Enum.take(5)
    p2_cards = String.split(cards_string, " ") |> Enum.take(-5)

    p1_ranking = ranking(p1_cards)
    p2_ranking = ranking(p2_cards)

    cond do
      p1_ranking < p2_ranking -> :p1
      p1_ranking > p2_ranking -> :p2
    end
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

  def flush?(suites) do
    case suites do
      ["C", "C", "C", "C", "C"] -> true
      ["D", "D", "D", "D", "D"] -> true
      ["S", "S", "S", "S", "S"] -> true
      ["H", "H", "H", "H", "H"] -> true
      _ -> false
    end
  end
end
