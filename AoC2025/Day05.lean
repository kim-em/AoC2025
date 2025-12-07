/-
  # Advent of Code 2025 - Day 05: Cafeteria
-/
import AoC2025.Day05.Basic

namespace AoC2025.Day05

-- Part 1: Count how many available ingredient IDs are fresh
def part1 (input : String) : String :=
  let (ranges, ids) := parseInput input
  let freshCount := ids.filter (inAnyRange ranges) |>.length
  toString freshCount

-- Part 2: Count total unique fresh IDs covered by all ranges
def part2 (input : String) : String :=
  let (ranges, _) := parseInput input
  let count := countFreshIds ranges
  toString count

end AoC2025.Day05
