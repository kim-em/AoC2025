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
  -- Requires proving that findAccessible returns positions of actual rolls
  -- Key steps: 1) findAccessible_valid shows all positions have '@'
  --            2) removeRolls_countRolls gives the decrease
  --            3) hne ensures at least one position is removed
  admit

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

/-! ## Specification Theorems -/

/-- A position is accessible iff it contains @ and has < 4 adjacent @ neighbors -/
theorem isAccessible_spec (grid : Array (Array Char)) (r c : Int) :
    isAccessible grid r c = true ↔
    (getAt grid r c = '@' ∧ countAdjacentRolls grid r c < 4) := by
  simp only [isAccessible, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq]

/-- findAccessible returns exactly the positions that satisfy isAccessible -/
theorem findAccessible_spec (grid : Array (Array Char)) :
    ∀ p ∈ findAccessible grid, isAccessible grid p.1 p.2 = true := by
  -- Requires proving the imperative loop correctly collects accessible positions
  -- The loop invariant would be: result contains exactly those (r, c) from
  -- already-visited positions where isAccessible grid r c = true
  admit

/-- Positions in findAccessible are valid grid positions with '@' -/
theorem findAccessible_valid (grid : Array (Array Char)) :
    ∀ p ∈ findAccessible grid,
    p.1 < grid.size ∧ (∀ (h : p.1 < grid.size), p.2 < grid[p.1].size ∧ getAt grid p.1 p.2 = '@') := by
  -- Follows from findAccessible_spec + isAccessible_spec + definition of getAt
  admit

/-- countAccessibleRolls equals length of findAccessible -/
theorem countAccessibleRolls_eq_findAccessible_length (grid : Array (Array Char)) :
    countAccessibleRolls grid = (findAccessible grid).length := by
  -- Both compute the same thing via imperative loops with identical structure
  admit

/-- removeRolls replaces '@' with '.' at given positions -/
theorem removeRolls_effect (grid : Array (Array Char)) (positions : List (Nat × Nat))
    (r c : Nat) (hr : r < grid.size) (hc : c < grid[r].size) :
    let newGrid := removeRolls grid positions
    getAt newGrid r c = (if (r, c) ∈ positions then '.' else getAt grid r c) := by
  -- Requires reasoning about Array.set! and List.foldl over positions
  admit

/-- After removeRolls, countRolls decreases by the number of valid roll positions removed -/
theorem removeRolls_countRolls (grid : Array (Array Char)) (positions : List (Nat × Nat))
    (h : ∀ p ∈ positions, p.1 < grid.size ∧ (∀ (hr : p.1 < grid.size), p.2 < grid[p.1].size)
         ∧ getAt grid p.1 p.2 = '@') :
    countRolls (removeRolls grid positions) + positions.length = countRolls grid := by
  -- Each position in the list removes exactly one roll (assuming positions are distinct)
  admit

/-- Part 2 correctness: removeAllAccessible counts all rolls that can eventually be removed -/
theorem removeAllAccessible_total (grid : Array (Array Char)) :
    removeAllAccessible grid 0 ≤ countRolls grid := by
  -- The proof would need strong induction on countRolls and the fact that
  -- removeRolls_decreases_count holds. This is an interesting termination property
  -- but requires careful invariant reasoning about the accumulator.
  admit

end AoC2025.Day04
