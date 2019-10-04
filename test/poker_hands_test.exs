defmodule PokerHandsTest do
  use ExUnit.Case

  # @tag :skip
  describe ".winner?/1" do
    test "Royal flush beats all other hands" do
      assert PokerHands.winner?("TC JC QC KC AC 7D 2S 5D 3S AC") == :p1
      assert PokerHands.winner?("7D 2S 5D 3S AC TC JC QC KC AC") == :p2
    end

    test "Straight high card beats a lower straight" do
      assert PokerHands.winner?("TH JC QC KC AC 9D TS JD QS KC") == :p1
      assert PokerHands.winner?("9D TS JD QS KC TH JC QC KC AC") == :p2
    end

    test "Competing Straight Flushes winner goes to the high card" do
      assert PokerHands.winner?("3H 4H 5H 6H 7H 9D TD JD QD KD") == :p2
      assert PokerHands.winner?("9D TD JD QD KD AH 2H 3H 4H 5H ") == :p1
    end

    test "Four of a kind ranks 3 and beats all but royal and straight flushes" do
      assert PokerHands.winner?("3H 3D 5H 3S 3C 2D TD JD QD KD") == :p1
      assert PokerHands.winner?("3H 3D 5H 3S 3C 9D TD JD QD KD") == :p2
      assert PokerHands.winner?("3H 3D 5H 3S 3C TD JD QD KD AD") == :p2
    end

    test "Four of a kind ties go to player with higher set of four" do
      assert PokerHands.winner?("3H 3D 2H 3S 3C JD JS JC JH TD") == :p2
      assert PokerHands.winner?("JD JS JC JH TD 3H 3D 5H 3S 3C") == :p1
    end

    test "Four of a kind ties go to player with high card if same set of four" do
      assert PokerHands.winner?("JD JS JC JH QD JD JS JC JH KD") == :p2
    end

    test "Four of a kind ties if identical hand values" do
      assert PokerHands.winner?("JD JS JC JH QD JD JS JC JH QD") == :tie
    end

    test "Full House hands rank 4 and contains pair and set of three" do
      assert PokerHands.winner?("3H 3D 3S 5S 5C 2D TD JD QD KD") == :p1
    end

    test "Full House ties go to stronger set of 3" do
      assert PokerHands.winner?("AH AD AS 2H 2D KH KD KS QH QD") == :p1
    end

    test "Full House ties go to stronger pair if shared set of 3" do
      assert PokerHands.winner?("AH AD AS 2H 2D AH AD AS QH QD") == :p2
    end

    test "Full House ties if identical set of 3 and pair" do
      assert PokerHands.winner?("AH AD AS 2H 2D AH AD AS 2H 2D") == :tie
    end
  end

  describe ".straight_tie_breaker/2" do
    test "It returns the player with the highest card value" do
      p1_values = ["2", "3", "4", "5", "6"]
      p2_values = ["3", "4", "5", "6", "7"]

      assert PokerHands.straight_tie_breaker(p1_values, p2_values) == :p2
    end

    test "It treats Aces as a low card in a A-5 Straight" do
      p1_values = ["2", "3", "4", "5", "A"]
      p2_values = ["3", "4", "5", "6", "7"]

      assert PokerHands.straight_tie_breaker(p1_values, p2_values) == :p2
    end

    test "It treats Aces as a high card in a T-A Straight" do
      p1_values = ["A", "J", "K", "Q", "T"]
      p2_values = ["2", "3", "4", "5", "A"]

      assert PokerHands.straight_tie_breaker(p1_values, p2_values) == :p1
    end

    test "It can handle ties if same high card straight" do
      p1_values = ["A", "J", "K", "Q", "T"]
      p2_values = ["A", "J", "K", "Q", "T"]

      assert PokerHands.straight_tie_breaker(p1_values, p2_values) == :tie
    end
  end

  describe ".cards/2" do
    test "It splits a string of space separated cards into a list" do
      cards = "TC JC QC KC AC 7D 2S 5D 3S AC"

      assert PokerHands.cards(cards, :p1) == ["TC", "JC", "QC", "KC", "AC"]
      assert PokerHands.cards(cards, :p2) == ["7D", "2S", "5D", "3S", "AC"]
    end
  end

  describe ".values/1" do
    test "It maps a list of cards into a list their values sorted" do
      assert PokerHands.values(["2D", "3D", "4D", "5D", "6D"]) == ["2", "3", "4", "5", "6"]
      assert PokerHands.values(["2D", "4D", "QD", "KD", "AD"]) == ["2", "4", "A", "K", "Q"]
    end
  end

  describe ".suites/1" do
    test "It maps a list of cards suites" do
      assert PokerHands.suites(["2D", "3D", "4D", "5D", "6D"]) == ["D", "D", "D", "D", "D"]
      assert PokerHands.suites(["2C", "3D", "4H", "5S", "6D"]) == ["C", "D", "H", "S", "D"]
    end
  end

  describe ".royal_flush?/2" do
    test "It returns true if the hand is a Royal Flush" do
      assert PokerHands.royal_flush?(["A", "J", "K", "Q", "T"], ["D", "D", "D", "D", "D"]) == true
      assert PokerHands.royal_flush?(["A", "J", "K", "Q", "T"], ["H", "H", "H", "H", "H"]) == true
      assert PokerHands.royal_flush?(["A", "J", "K", "Q", "T"], ["S", "S", "S", "S", "S"]) == true
      assert PokerHands.royal_flush?(["A", "J", "K", "Q", "T"], ["C", "C", "C", "C", "C"]) == true
      assert PokerHands.royal_flush?(["2", "J", "K", "Q", "T"], ["C", "C", "C", "C", "C"]) == false

      # Note the values must be sorted alphabetically
      # which is taken care of by .values/1
      assert PokerHands.royal_flush?(["T", "J", "Q", "K", "A"], ["C", "C", "C", "C", "C"]) == false
    end
  end

  describe ".flush?/1" do
    test "It checks if a list of suites is a Flush" do
      assert PokerHands.flush?(["C", "C", "C", "C", "C"]) == true
      assert PokerHands.flush?(["D", "D", "D", "D", "D"]) == true
      assert PokerHands.flush?(["S", "S", "S", "S", "S"]) == true
      assert PokerHands.flush?(["H", "H", "H", "H", "H"]) == true
      assert PokerHands.flush?(["D", "H", "C", "H", "S"]) == false
    end
  end

  describe ".straight?/1" do
    test "It returns true if a hand is a Straight" do
      assert PokerHands.straight?(["2", "3", "4", "5", "A"]) == true
      assert PokerHands.straight?(["2", "3", "4", "5", "6"]) == true
      assert PokerHands.straight?(["3", "4", "5", "6", "7"]) == true
      assert PokerHands.straight?(["4", "5", "6", "7", "8"]) == true
      assert PokerHands.straight?(["5", "6", "7", "8", "9"]) == true
      assert PokerHands.straight?(["6", "7", "8", "9", "T"]) == true
      assert PokerHands.straight?(["7", "8", "9", "J", "T"]) == true
      assert PokerHands.straight?(["8", "9", "J", "Q", "T"]) == true
      assert PokerHands.straight?(["9", "J", "K", "Q", "T"]) == true
      assert PokerHands.straight?(["A", "J", "K", "Q", "T"]) == true

      assert PokerHands.straight?(["3", "4", "5", "A", "K"]) == false
      assert PokerHands.straight?(["3", "4", "5", "9", "T"]) == false

      # Cannot loop the deck
      assert PokerHands.straight?(["2", "3", "A", "K", "Q"]) == false
    end
  end

  describe ".straight_flush?/2" do
    test "It returns true if a hand is a Straight Flush" do
      assert PokerHands.straight_flush?(["2", "3", "4", "5", "A"], ["C", "C", "C", "C", "C"]) == true
      assert PokerHands.straight_flush?(["9", "J", "K", "Q", "T"], ["H", "H", "H", "H", "H"]) == true

      assert PokerHands.straight_flush?(["2", "3", "4", "5", "A"], ["C", "S", "C", "C", "C"]) == false
      assert PokerHands.straight_flush?(["9", "J", "K", "Q", "T"], ["H", "H", "H", "C", "H"]) == false
    end
  end
end
