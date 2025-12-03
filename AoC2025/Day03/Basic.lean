/-
  # Day 03 - Parsing and Data Structures
-/
import AoC2025.Basic

namespace AoC2025.Day03

/-- Parse a single character digit to a natural number -/
def charToDigit (c : Char) : Nat :=
  c.toNat - '0'.toNat

/-- Parse a bank (line) to a list of digits -/
def parseBank (s : String) : List Nat :=
  s.toList.map charToDigit

/-- Find maximum joltage from a bank by picking 2 batteries -/
def maxJoltage (bank : List Nat) : Nat := Id.run do
  -- We need to maximize d1 * 10 + d2 where d1 is at position i, d2 at position j, i < j
  let arr := bank.toArray
  let n := arr.size
  if n < 2 then return 0
  -- For each pair (i, j) with i < j, compute arr[i] * 10 + arr[j]
  let mut best := 0
  for i in [0 : n - 1] do
    for j in [i + 1 : n] do
      let val := arr[i]! * 10 + arr[j]!
      if val > best then
        best := val
  return best

/-- Find maximum joltage from a bank by picking exactly k batteries (Part 2 uses k=12) -/
def maxJoltageK (bank : List Nat) (k : Nat) : Nat := Id.run do
  -- Greedy approach: at each position, pick the largest digit that leaves enough for remaining
  let arr := bank.toArray
  let n := arr.size
  if n < k then return 0

  let mut result : Nat := 0
  let mut pos : Nat := 0  -- current position in array
  let mut remaining := k  -- digits still needed

  while remaining > 0 do
    -- We need to pick `remaining` more digits from positions [pos, n)
    -- For the next digit, we can choose from [pos, n - remaining + 1)
    -- (we must leave at least remaining-1 positions for the rest)
    let lastValid := n - remaining

    -- Find the maximum digit in range [pos, lastValid]
    let mut bestDigit := 0
    let mut bestPos := pos
    for i in [pos : lastValid + 1] do
      if arr[i]! > bestDigit then
        bestDigit := arr[i]!
        bestPos := i

    result := result * 10 + bestDigit
    pos := bestPos + 1
    remaining := remaining - 1

  return result

end AoC2025.Day03
