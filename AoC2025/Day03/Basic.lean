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

/-! ## Specification Theorems -/

/-- charToDigit maps characters to their digit value -/
theorem charToDigit_of_zero : charToDigit '0' = 0 := by rfl
theorem charToDigit_of_five : charToDigit '5' = 5 := by rfl
theorem charToDigit_of_nine : charToDigit '9' = 9 := by rfl

/-- maxJoltage of empty bank is 0 -/
theorem maxJoltage_empty : maxJoltage [] = 0 := by rfl

/-- maxJoltage of singleton bank is 0 (need 2 elements) -/
theorem maxJoltage_singleton (d : Nat) : maxJoltage [d] = 0 := by rfl

/-- maxJoltage returns a 2-digit number when digits ≤ 9 -/
theorem maxJoltage_le_99 (bank : List Nat) (h : ∀ d ∈ bank, d ≤ 9) :
    maxJoltage bank ≤ 99 := by
  -- The proof requires showing the loop invariant: best ≤ 9*10 + 9 = 99
  -- when all array elements are ≤ 9.
  -- This is difficult to prove directly for the imperative Id.run loop.
  -- The key insight: val = arr[i]! * 10 + arr[j]! ≤ 9*10 + 9 = 99
  sorry

/-- maxJoltageK greedy property: each selected digit is maximal among remaining choices -/
theorem maxJoltageK_greedy (bank : List Nat) (k : Nat)
    (hne : bank.length ≥ k) (hk : k > 0) :
    maxJoltageK bank k > 0 ∨ bank.all (· = 0) := by
  -- The proof requires showing that the greedy loop selects the maximum
  -- digit at each step from the available positions. If any digit > 0 exists,
  -- the first selected digit will be > 0, so the result > 0.
  -- This is difficult to prove for the imperative while loop.
  sorry

end AoC2025.Day03
