# PokerHands

Solution to Project Euler Problem #54 - Poker Hands
- Task was to build an application to determine the winner between two poker hands
- Given a text file `poker.txt` with 1000 hands, how many hands does Player 1 win
https://projecteuler.net/problem=54

Built with [Elixir](https://elixir-lang.org/)

## Format

Input
- string
- Example: `8C TS KC 9H 4S 7D 2S 5D 3S AC`
- First 5 cards are Player 1 cards
- Last 5 cards are Player 2 cards
- First character is the value of the card (2 - Two, T - Ten, K - King)
- Second character denotes the suite (S - Spades, H - Hearts, C - Clubs, D - Diamonds)

## Poker Hand Rankings Tiebreakers

https://www.adda52.com/poker/poker-rules/cash-game-rules/tie-breaker-rules
