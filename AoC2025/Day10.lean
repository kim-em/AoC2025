/-
  # Advent of Code 2025 - Day 10
-/
import AoC2025.Day10.Basic

namespace AoC2025.Day10

-- Part 1
def part1 (input : String) : String :=
  let machines := parseInput input
  let results := machines.map solveMachine
  -- Sum all minimum button presses
  let total := results.foldl (fun acc r =>
    match r with
    | some n => acc + n
    | none => acc) 0
  toString total

-- Part 2
def part2 (input : String) : String :=
  let machines := parseInput input
  let results := machines.map solveMachineJoltage
  let total := results.foldl (fun acc r =>
    match r with
    | some n => acc + n
    | none => acc) 0
  toString total

end AoC2025.Day10
