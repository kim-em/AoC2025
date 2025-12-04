/-
  # Advent of Code 2025 - Day 04
-/
import AoC2025.Day04.Basic

namespace AoC2025.Day04

/-- Parse input into a 2D grid of characters -/
def parseGrid (input : String) : Array (Array Char) :=
  let lns := AoC2025.lines input
  lns.toArray.map (·.toList.toArray)

/-- Get the character at position (row, col), or '.' if out of bounds -/
def getAt (grid : Array (Array Char)) (row col : Int) : Char :=
  if row < 0 || col < 0 then '.'
  else
    let r := row.toNat
    let c := col.toNat
    if h : r < grid.size then
      let rowArr := grid[r]
      if c < rowArr.size then rowArr[c]! else '.'
    else '.'

/-- Count adjacent paper rolls (@) for a given position -/
def countAdjacentRolls (grid : Array (Array Char)) (row col : Int) : Nat :=
  let neighbors := [
    (row - 1, col - 1), (row - 1, col), (row - 1, col + 1),
    (row,     col - 1),                 (row,     col + 1),
    (row + 1, col - 1), (row + 1, col), (row + 1, col + 1)
  ]
  neighbors.foldl (fun acc (r, c) =>
    if getAt grid r c == '@' then acc + 1 else acc) 0

/-- Check if a roll at position is accessible (fewer than 4 adjacent rolls) -/
def isAccessible (grid : Array (Array Char)) (row col : Int) : Bool :=
  getAt grid row col == '@' && countAdjacentRolls grid row col < 4

/-- Count all accessible paper rolls in the grid -/
def countAccessibleRolls (grid : Array (Array Char)) : Nat := Id.run do
  let numRows := grid.size
  let numCols := if grid.size > 0 then grid[0]!.size else 0
  let mut count := 0
  for r in [:numRows] do
    for c in [:numCols] do
      if isAccessible grid r c then
        count := count + 1
  return count

-- Part 1
def part1 (input : String) : String :=
  let grid := parseGrid input
  let count := countAccessibleRolls grid
  toString count

/-- Find all accessible positions in the grid -/
def findAccessible (grid : Array (Array Char)) : List (Nat × Nat) := Id.run do
  let numRows := grid.size
  let numCols := if grid.size > 0 then grid[0]!.size else 0
  let mut result : List (Nat × Nat) := []
  for r in [:numRows] do
    for c in [:numCols] do
      if isAccessible grid r c then
        result := (r, c) :: result
  return result

/-- Remove rolls at given positions from the grid -/
def removeRolls (grid : Array (Array Char)) (positions : List (Nat × Nat)) : Array (Array Char) :=
  positions.foldl (fun g (r, c) =>
    if h : r < g.size then
      let row := g[r]
      if c < row.size then
        g.set! r (row.set! c '.')
      else g
    else g) grid

/-- Count total number of rolls (@) in the grid -/
def countRolls (grid : Array (Array Char)) : Nat :=
  grid.foldl (fun acc row => acc + row.foldl (fun a c => if c == '@' then a + 1 else a) 0) 0

/-- Removing accessible rolls decreases the roll count -/
theorem removeRolls_decreases_count (grid : Array (Array Char)) (accessible : List (Nat × Nat))
    (hne : ¬accessible.isEmpty) (hacc : accessible = findAccessible grid) :
    countRolls (removeRolls grid accessible) < countRolls grid := by
  sorry  -- Requires proving that findAccessible returns positions of actual rolls

/-- Repeatedly remove accessible rolls until none remain, return total removed.
    Termination: each iteration removes at least one roll, so countRolls decreases. -/
def removeAllAccessible (grid : Array (Array Char)) (totalRemoved : Nat) : Nat :=
  let accessible := findAccessible grid
  if h_empty : accessible.isEmpty then
    totalRemoved
  else
    let newGrid := removeRolls grid accessible
    have _hne : ¬accessible.isEmpty := h_empty  -- Used in decreasing_by
    removeAllAccessible newGrid (totalRemoved + accessible.length)
termination_by countRolls grid
decreasing_by
  simp_wf
  exact removeRolls_decreases_count grid accessible _hne rfl

-- Part 2
def part2 (input : String) : String :=
  let grid := parseGrid input
  let total := removeAllAccessible grid 0
  toString total

end AoC2025.Day04
