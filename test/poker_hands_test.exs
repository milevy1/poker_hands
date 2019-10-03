defmodule PokerHandsTest do
  use ExUnit.Case

  # @tag :skip
  test "Royal flush beats all other hands" do
    assert PokerHands.winner?("TC JC QC KC AC 7D 2S 5D 3S AC") == :p1
    assert PokerHands.winner?("7D 2S 5D 3S AC TC JC QC KC AC") == :p2
  end

  describe ".cards/2" do
    test "It splits a string of space separated cards into a list" do
      cards = "TC JC QC KC AC 7D 2S 5D 3S AC"

      assert PokerHands.cards(cards, :p1) == ["TC", "JC", "QC", "KC", "AC"]
      assert PokerHands.cards(cards, :p2) == ["7D", "2S", "5D", "3S", "AC"]
    end
  end

  describe ".ranking/1" do
    test "It ranks a Royal Flush as a 1" do
      assert PokerHands.ranking(["TC", "JC", "QC", "KC", "AC"]) == 1
      assert PokerHands.ranking(["TH", "JH", "QH", "KH", "AH"]) == 1
      assert PokerHands.ranking(["TS", "JS", "QS", "KS", "AS"]) == 1
      assert PokerHands.ranking(["TD", "JD", "QD", "KD", "AD"]) == 1
      assert PokerHands.ranking(["TD", "JC", "QC", "KC", "AC"]) != 1
    end

    test "It ranks a Normal Flush as a 5" do
      assert PokerHands.ranking(["2D", "4D", "QD", "KD", "AD"]) == 5
      assert PokerHands.ranking(["2H", "4H", "QH", "KH", "AH"]) == 5
      assert PokerHands.ranking(["2S", "4S", "QS", "KS", "AS"]) == 5
      assert PokerHands.ranking(["2C", "4C", "QC", "KC", "AC"]) == 5
      assert PokerHands.ranking(["2C", "4D", "QD", "KD", "AD"]) != 5
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
    end
  end
end
