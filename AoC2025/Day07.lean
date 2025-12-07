/-
  # Advent of Code 2025 - Day 07: Laboratories
-/
import AoC2025.Day07.Basic

namespace AoC2025.Day07

-- Part 1: Count how many times beams are split
def part1 (input : String) : String :=
  let (grid, startPos) := parseGrid input
  let splits := simulateBeams grid startPos
  toString splits

-- Part 2: Count number of timelines (each split creates 2 timelines)
def part2 (input : String) : String :=
  let (grid, startPos) := parseGrid input
  let timelines := simulateTimelines grid startPos
  toString timelines

end AoC2025.Day07
