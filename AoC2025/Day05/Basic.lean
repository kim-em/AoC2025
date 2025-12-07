/-
  # Day 05: Cafeteria - Parsing and helper functions
-/
import AoC2025.Basic

namespace AoC2025.Day05

/-- A range of fresh ingredient IDs (inclusive) -/
structure Range where
  lo : Nat
  hi : Nat
  deriving Repr

/-- Parse a range like "3-5" -/
def parseRange (s : String) : Option Range := do
  let parts := s.splitOn "-"
  if parts.length != 2 then none
  else
    let lo ← parts[0]!.trim.toNat?
    let hi ← parts[1]!.trim.toNat?
    some ⟨lo, hi⟩

/-- Check if a value is in a range -/
def Range.contains (r : Range) (n : Nat) : Bool :=
  r.lo ≤ n && n ≤ r.hi

/-- Check if a value is in any of the ranges -/
def inAnyRange (ranges : List Range) (n : Nat) : Bool :=
  ranges.any (·.contains n)

/-- Sort ranges by lo, then hi -/
def Range.lt (r1 r2 : Range) : Bool :=
  r1.lo < r2.lo || (r1.lo = r2.lo && r1.hi < r2.hi)

/-- Merge a sorted list of ranges into non-overlapping ranges -/
def mergeRanges (ranges : List Range) : List Range :=
  let sorted := ranges.toArray.qsort Range.lt |>.toList
  sorted.foldl (fun acc r =>
    match acc with
    | [] => [r]
    | last :: rest =>
      -- Ranges overlap or are adjacent if last.hi >= r.lo - 1
      if last.hi + 1 >= r.lo then
        { lo := last.lo, hi := max last.hi r.hi } :: rest
      else
        r :: acc
  ) [] |>.reverse

/-- Count total IDs covered by ranges (after merging) -/
def countFreshIds (ranges : List Range) : Nat :=
  let merged := mergeRanges ranges
  merged.foldl (fun acc r => acc + (r.hi - r.lo + 1)) 0

/-- Parse the input: fresh ranges (before blank line) and ingredient IDs (after) -/
def parseInput (input : String) : (List Range × List Nat) :=
  let allLines := lines input
  let (rangeLines, rest) := allLines.span (·.length > 0)
  let idLines := rest.drop 1  -- skip blank line
  let ranges := rangeLines.filterMap parseRange
  let ids := idLines.filterMap (·.toNat?)
  (ranges, ids)

end AoC2025.Day05
