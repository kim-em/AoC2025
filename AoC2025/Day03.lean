/-
  # Advent of Code 2025 - Day 03
-/
import AoC2025.Day03.Basic

namespace AoC2025.Day03

-- Part 1
def part1 (input : String) : String :=
  let banks := AoC2025.lines input |>.map parseBank
  let total := banks.foldl (fun acc bank => acc + maxJoltage bank) 0
  toString total

-- Part 2
def part2 (input : String) : String :=
  let banks := AoC2025.lines input |>.map parseBank
  let total := banks.foldl (fun acc bank => acc + maxJoltageK bank 12) 0
  toString total

end AoC2025.Day03
