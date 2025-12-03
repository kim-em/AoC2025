/-
  # Advent of Code 2025 - Day 02
-/
import AoC2025.Day02.Basic

namespace AoC2025.Day02

-- Part 1
def part1 (input : String) : String :=
  let ranges := parseRanges input
  let total := ranges.foldl (fun acc r => acc + sumInvalidInRange r) 0
  toString total

-- Part 2
def part2 (input : String) : String :=
  let ranges := parseRanges input
  let total := ranges.foldl (fun acc r => acc + sumInvalidInRangePart2 r) 0
  toString total

end AoC2025.Day02
