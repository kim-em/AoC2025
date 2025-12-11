/-
  # Advent of Code 2025 - Day 11
-/
import AoC2025.Day11.Basic
import Std.Data.HashMap

namespace AoC2025.Day11

open Std (HashMap)

-- Part 1
def part1 (input : String) : String :=
  let graph := parseGraph input
  let (_, count) := countPathsTo graph "you" "out" .empty
  toString count

-- Part 2
def part2 (input : String) : String :=
  let graph := parseGraph input
  let (_, count) := countPathsViaBoth graph "svr" "dac" "fft" "out" .empty
  toString count

end AoC2025.Day11
