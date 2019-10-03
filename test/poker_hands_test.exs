defmodule PokerHandsTest do
  use ExUnit.Case

  # @tag :skip
  test "Royal flush beats all other hands" do
    assert PokerHands.winner?("TC JC QC KC AC 7D 2S 5D 3S AC") == :p1
    assert PokerHands.winner?("7D 2S 5D 3S AC TC JC QC KC AC") == :p2
  end
end
