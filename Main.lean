import AoC2025

open AoC2025

def runDay (day : Nat) : IO Unit := do
  let input ← readInput day
  match day with
  | 1 =>
    IO.println s!"Day 01 Part 1: {Day01.part1 input}"
    IO.println s!"Day 01 Part 2: {Day01.part2 input}"
  | 2 =>
    IO.println s!"Day 02 Part 1: {Day02.part1 input}"
    IO.println s!"Day 02 Part 2: {Day02.part2 input}"
  | 3 =>
    IO.println s!"Day 03 Part 1: {Day03.part1 input}"
    IO.println s!"Day 03 Part 2: {Day03.part2 input}"
  | _ => IO.println s!"Day {day} not implemented yet"

def main (args : List String) : IO Unit := do
  match args with
  | [dayStr] =>
    match dayStr.toNat? with
    | some day => runDay day
    | none => IO.println "Usage: aoc2025 <day>"
  | _ => IO.println "Usage: aoc2025 <day>"
