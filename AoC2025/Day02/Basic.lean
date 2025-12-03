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

/-- Compute sum of invalid numbers for a given k (digit half-length) in range -/
def sumInvalidForK (r : Range) (k : Nat) : Nat :=
  let multiplier := Nat.pow 10 k + 1  -- e.g., k=1 → 11, k=2 → 101, k=3 → 1001
  let baseMin := if k == 1 then 1 else Nat.pow 10 (k - 1)  -- e.g., k=1 → 1, k=2 → 10, k=3 → 100
  let baseMax := Nat.pow 10 k - 1  -- e.g., k=1 → 9, k=2 → 99, k=3 → 999
  -- Invalid numbers of 2k digits are: multiplier * base for base in [baseMin, baseMax]
  -- We need: r.lo ≤ multiplier * base ≤ r.hi
  -- So: ceil(r.lo / multiplier) ≤ base ≤ floor(r.hi / multiplier)
  let minBase := (r.lo + multiplier - 1) / multiplier  -- ceiling division
  let maxBase := r.hi / multiplier  -- floor division
  -- Clamp to valid range for this digit count
  let actualMin := max minBase baseMin
  let actualMax := min maxBase baseMax
  if actualMin ≤ actualMax then
    -- Sum of multiplier * base for base in [actualMin, actualMax]
    -- = multiplier * (actualMin + actualMin+1 + ... + actualMax)
    -- = multiplier * (sum from actualMin to actualMax)
    -- = multiplier * (actualMax - actualMin + 1) * (actualMin + actualMax) / 2
    let count := actualMax - actualMin + 1
    let sumBases := count * (actualMin + actualMax) / 2
    multiplier * sumBases
  else
    0

/-- Find all invalid IDs in a range and sum them (Part 1: exactly doubled) -/
def sumInvalidInRange (r : Range) : Nat :=
  -- We need to find invalid numbers in [r.lo, r.hi]
  -- Invalid numbers have even digit counts, so we can be smarter
  -- For each even digit count, invalid numbers are: aa, abab, abcabc, etc.
  -- They form: n * (10^k + 1) where k = number of digits in n
  -- For 2 digits: 11, 22, ..., 99 = 11*1, 11*2, ..., 11*9
  -- For 4 digits: 1010, 1111, 1212, ..., 9999 = 101*10, 101*11, ..., 101*99
  -- For 6 digits: 100100, ..., 999999 = 1001*100, ..., 1001*999
  -- Pattern: for 2k digits, multiplier is (10^k + 1), base ranges from 10^(k-1) to 10^k - 1
  List.range 11 |>.drop 1 |>.foldl (fun acc k => acc + sumInvalidForK r k) 0

/-- Check if a number is invalid for Part 2 (repeated at least twice) -/
def isInvalidPart2 (n : Nat) : Bool :=
  let s := toString n
  let len := s.length
  -- Check all divisors d of len where len/d >= 2
  List.range len |>.drop 1 |>.any fun d =>
    if len % d == 0 && len / d >= 2 then
      let rep := len / d
      let base := s.take d
      -- Check if all rep copies equal the base
      List.range rep |>.all fun i =>
        s.extract ⟨i * d⟩ ⟨(i + 1) * d⟩ == base
    else false

/-- Compute (10^d - 1) / (10^d - 1) style multiplier for base of d digits repeated k times -/
def repMultiplier (d k : Nat) : Nat :=
  -- Number is base * (10^(d*(k-1)) + 10^(d*(k-2)) + ... + 1)
  -- = base * sum_{i=0}^{k-1} 10^(d*i)
  -- = base * (10^(d*k) - 1) / (10^d - 1)
  (Nat.pow 10 (d * k) - 1) / (Nat.pow 10 d - 1)

/-- For Part 2: sum invalid numbers with d-digit base repeated k times in range -/
def sumInvalidForDK (r : Range) (d k : Nat) : Nat :=
  let mult := repMultiplier d k
  let baseMin := if d == 1 then 1 else Nat.pow 10 (d - 1)
  let baseMax := Nat.pow 10 d - 1
  let minBase := (r.lo + mult - 1) / mult  -- ceiling
  let maxBase := r.hi / mult
  let actualMin := max minBase baseMin
  let actualMax := min maxBase baseMax
  if actualMin ≤ actualMax then
    let count := actualMax - actualMin + 1
    let sumBases := count * (actualMin + actualMax) / 2
    mult * sumBases
  else 0

/-- Collect all invalid numbers in range for Part 2, avoiding double counting -/
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
