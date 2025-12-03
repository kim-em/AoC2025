/-
  # Common utilities for Advent of Code 2025
-/
namespace AoC2025

/-- Read input file for a given day -/
def readInput (day : Nat) : IO String := do
  let dayStr := if day < 10 then s!"0{day}" else s!"{day}"
  IO.FS.readFile s!"data/day{dayStr}.txt"

/-- Split string into lines, removing empty trailing lines -/
def lines (s : String) : List String :=
  s.splitOn "\n" |>.reverse |>.dropWhile (·.isEmpty) |>.reverse

/-- Parse a string as a natural number -/
def parseNat? (s : String) : Option Nat :=
  s.trim.toNat?

/-- Parse a string as an integer -/
def parseInt? (s : String) : Option Int :=
  s.trim.toInt?

end AoC2025
