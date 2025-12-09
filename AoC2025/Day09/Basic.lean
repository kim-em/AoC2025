/-
  # Day 09 - Parsing and Data Structures
-/
import AoC2025.Basic

namespace AoC2025.Day09

structure Point where
  x : Nat
  y : Nat
  deriving Repr, BEq, Inhabited

def parseLine (line : String) : Option Point := do
  let parts := line.split (· == ',')
  match parts with
  | [xStr, yStr] =>
    let x ← parseNat? xStr.trim
    let y ← parseNat? yStr.trim
    return { x, y }
  | _ => none

def parseInput (input : String) : List Point :=
  input.splitOn "\n"
  |> List.filterMap parseLine

end AoC2025.Day09
