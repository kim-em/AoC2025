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
  | 4 =>
    IO.println s!"Day 04 Part 1: {Day04.part1 input}"
    IO.println s!"Day 04 Part 2: {Day04.part2 input}"
  | 5 =>
    IO.println s!"Day 05 Part 1: {Day05.part1 input}"
    IO.println s!"Day 05 Part 2: {Day05.part2 input}"
  | 6 =>
    IO.println s!"Day 06 Part 1: {Day06.part1 input}"
    IO.println s!"Day 06 Part 2: {Day06.part2 input}"
  | 7 =>
    IO.println s!"Day 07 Part 1: {Day07.part1 input}"
    IO.println s!"Day 07 Part 2: {Day07.part2 input}"
  | 8 =>
    IO.println s!"Day 08 Part 1: {Day08.part1 input}"
    IO.println s!"Day 08 Part 2: {Day08.part2 input}"
  | 9 =>
    IO.println s!"Day 09 Part 1: {Day09.part1 input}"
    IO.println s!"Day 09 Part 2: {Day09.part2 input}"
  | 10 =>
    IO.println s!"Day 10 Part 1: {Day10.part1 input}"
    IO.println s!"Day 10 Part 2: {Day10.part2 input}"
  | 11 =>
    IO.println s!"Day 11 Part 1: {Day11.part1 input}"
    IO.println s!"Day 11 Part 2: {Day11.part2 input}"
  | 12 =>
    IO.println s!"Day 12 Part 1: {Day12.part1 input}"
    IO.println s!"Day 12 Part 2: {Day12.part2 input}"
  | _ => IO.println s!"Day {day} not implemented yet"

def main (args : List String) : IO Unit := do
  match args with
  | [dayStr] =>
    match dayStr.toNat? with
    | some day => runDay day
    | none => IO.println "Usage: aoc2025 <day>"
  | _ => IO.println "Usage: aoc2025 <day>"
