/-
  # Advent of Code 2025 - Day 06: Trash Compactor
-/
import AoC2025.Day06.Basic

namespace AoC2025.Day06

-- Part 1: Sum of all problem results
def part1 (input : String) : String :=
  let problems := parseProblems input
  let results := problems.map Problem.eval
  let total := results.foldl (· + ·) 0
  toString total

-- Part 2: Read problems right-to-left, each column is a number (top=MSB)
def part2 (input : String) : String :=
  let problems := parseProblemsPart2 input
  let results := problems.map Problem.eval
  let total := results.foldl (· + ·) 0
  toString total

end AoC2025.Day06
