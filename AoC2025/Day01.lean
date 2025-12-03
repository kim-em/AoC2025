/-
  # Advent of Code 2025 - Day 01
-/
import AoC2025.Day01.Basic

namespace AoC2025.Day01

-- Part 1: Count how many times dial points at 0 after each rotation
def part1 (input : String) : String :=
  let rotations := parseInput input
  let (_, count) := rotations.foldl (fun (pos, count) rot =>
    let newPos := applyRotation pos rot
    let newCount := if newPos == 0 then count + 1 else count
    (newPos, newCount)
  ) (50, 0)
  toString count

-- Part 2: Count all clicks that land on 0 (during rotations too)
def part2 (input : String) : String :=
  let rotations := parseInput input
  let (_, count) := rotations.foldl (fun (pos, count) rot =>
    let crossings := countZeroCrossings pos rot
    let newPos := applyRotation pos rot
    (newPos, count + crossings)
  ) (50, 0)
  toString count

end AoC2025.Day01
