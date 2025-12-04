/-
  # Day 02 - Parsing and Data Structures
-/
import AoC2025.Basic

namespace AoC2025.Day02

/-- A range of product IDs -/
structure Range where
  lo : Nat
  hi : Nat
  deriving Repr

/-- Check if a number is "invalid" - i.e., consists of some digit sequence repeated twice -/
def isInvalid (n : Nat) : Bool :=
  let s := toString n
  let len := s.length
  -- Must have even length to be a doubled sequence
  if len % 2 != 0 then false
  else
    let half := len / 2
    let firstHalf := s.take half
    let secondHalf := s.drop half
    firstHalf == secondHalf

/-- Parse a single range like "11-22" -/
def parseRange? (s : String) : Option Range := do
  let parts := s.splitOn "-"
  if parts.length != 2 then none
  else
    let lo ← parts[0]!.toNat?
    let hi ← parts[1]!.toNat?
    some { lo, hi }

/-- Parse the input line into ranges -/
def parseRanges (input : String) : List Range :=
  let trimmed := input.trim.dropRightWhile (· == ',')
  trimmed.splitOn "," |>.filterMap parseRange?

/-- Compute (10^(d*k) - 1) / (10^d - 1) - multiplier for base of d digits repeated k times.
    E.g., repMultiplier 2 3 = 10101 (so 12 repeated 3 times = 12 * 10101 = 121212) -/
def repMultiplier (d k : Nat) : Nat :=
  (Nat.pow 10 (d * k) - 1) / (Nat.pow 10 d - 1)

/-- Sum of numbers in range [r.lo, r.hi] that are a d-digit base repeated k times.
    Uses closed-form arithmetic sum formula instead of iteration. -/
def sumRepetitionsInRange (r : Range) (d k : Nat) : Nat :=
  let mult := repMultiplier d k
  -- Valid bases for d digits: [10^(d-1), 10^d - 1], except d=1 uses [1, 9]
  let baseMin := if d == 1 then 1 else Nat.pow 10 (d - 1)
  let baseMax := Nat.pow 10 d - 1
  -- Find bases where mult * base falls in [r.lo, r.hi]
  let minBase := (r.lo + mult - 1) / mult  -- ceiling division
  let maxBase := r.hi / mult               -- floor division
  let actualMin := max minBase baseMin
  let actualMax := min maxBase baseMax
  if actualMin ≤ actualMax then
    -- Sum of mult * base for base in [actualMin, actualMax]
    -- = mult * Σ base = mult * (count * (actualMin + actualMax) / 2)
    let count := actualMax - actualMin + 1
    let sumBases := count * (actualMin + actualMax) / 2
    mult * sumBases
  else
    0

/-- Find all invalid IDs in a range and sum them (Part 1: exactly doubled).
    Invalid = d-digit base repeated exactly 2 times, for various d. -/
def sumInvalidInRange (r : Range) : Nat :=
  -- For each base digit count d in [1, 10], sum numbers with d-digit base repeated twice
  List.range 11 |>.drop 1 |>.foldl (fun acc d => acc + sumRepetitionsInRange r d 2) 0

/-- Check if a number is invalid for Part 2 (repeated at least twice).
    Used for testing/validation, not in the actual solution. -/
def isInvalidPart2 (n : Nat) : Bool :=
  let s := toString n
  let len := s.length
  -- Check all divisors d of len where len/d >= 2
  List.range len |>.drop 1 |>.any fun d =>
    if len % d == 0 && len / d >= 2 then
      let rep := len / d
      let base := s.take d
      List.range rep |>.all fun i =>
        (s.toSubstring.extract ⟨i * d⟩ ⟨(i + 1) * d⟩).toString == base
    else false

/-- Collect all invalid numbers in range for Part 2, avoiding double counting.
    A number can match multiple (d, k) patterns (e.g., 111111 = 1 repeated 6 times
    or 111 repeated twice), so we collect all matches and deduplicate. -/
def collectInvalidPart2 (r : Range) : List Nat := Id.run do
  let mut result : List Nat := []
  -- For each total digit count n in range 2..20
  for n in [2:21] do
    -- Check all divisors d where n/d >= 2
    for d in [1:n] do
      if n % d == 0 && n / d >= 2 then
        let k := n / d
        let mult := repMultiplier d k
        let baseMin := if d == 1 then 1 else Nat.pow 10 (d - 1)
        let baseMax := Nat.pow 10 d - 1
        let minBase := (r.lo + mult - 1) / mult
        let maxBase := r.hi / mult
        let actualMin := max minBase baseMin
        let actualMax := min maxBase baseMax
        for base in [actualMin : actualMax + 1] do
          let num := mult * base
          if num >= r.lo && num <= r.hi then
            result := num :: result
  result.eraseDups

/-- Sum all invalid IDs for Part 2 -/
def sumInvalidInRangePart2 (r : Range) : Nat :=
  let invalid := collectInvalidPart2 r
  invalid.foldl (· + ·) 0

end AoC2025.Day02
