/-
  # Advent of Code 2025 - Day 09
-/
import AoC2025.Day09.Basic
import Std.Data.HashSet

namespace AoC2025.Day09

def rectangleArea (p1 p2 : Point) : Nat :=
  let dx := if p1.x > p2.x then p1.x - p2.x + 1 else p2.x - p1.x + 1
  let dy := if p1.y > p2.y then p1.y - p2.y + 1 else p2.y - p1.y + 1
  dx * dy

def maxRectangleArea (points : List Point) : Nat :=
  let pairs := points.flatMap fun p1 =>
    points.filterMap fun p2 =>
      if p1 != p2 then some (rectangleArea p1 p2) else none
  pairs.foldl Nat.max 0

-- Part 1
def part1 (input : String) : String :=
  let points := parseInput input
  toString (maxRectangleArea points)

-- For Part 2, we need to determine which tiles are green
-- Green tiles are: perimeter of the polygon + interior
def isOnSegment (p a b : Point) : Bool :=
  let minX := min a.x b.x
  let maxX := max a.x b.x
  let minY := min a.y b.y
  let maxY := max a.y b.y
  if a.x == b.x then
    -- Vertical segment
    p.x == a.x && minY ≤ p.y && p.y ≤ maxY
  else if a.y == b.y then
    -- Horizontal segment
    p.y == a.y && minX ≤ p.x && p.x ≤ maxX
  else
    false

-- Check if point is inside polygon using ray casting
def isInsidePolygon (p : Point) (vertices : Array Point) : Bool := Id.run do
  let n := vertices.size
  let mut inside := false
  let mut j := n - 1
  for i in [0:n] do
    let vi := vertices[i]!
    let vj := vertices[j]!
    if ((vi.y > p.y) != (vj.y > p.y)) &&
       (p.x < (vj.x - vi.x) * (p.y - vi.y) / (vj.y - vi.y) + vi.x) then
      inside := !inside
    j := i
  return inside

def isGreenTile (p : Point) (redTiles : Array Point) : Bool := Id.run do
  -- Check if on perimeter
  let n := redTiles.size
  for i in [0:n] do
    let a := redTiles[i]!
    let b := redTiles[(i + 1) % n]!
    if isOnSegment p a b then
      return true
  -- Check if inside polygon
  return isInsidePolygon p redTiles

def isValidRectangleOpt (p1 p2 : Point) (redTiles : Array Point) (redSet : Std.HashSet (Nat × Nat)) : Bool := Id.run do
  let minX := min p1.x p2.x
  let maxX := max p1.x p2.x
  let minY := min p1.y p2.y
  let maxY := max p1.y p2.y
  -- Check all points in the rectangle
  for x in [minX:maxX+1] do
    for y in [minY:maxY+1] do
      let p := { x, y }
      if !(redSet.contains (x, y) || isGreenTile p redTiles) then
        return false
  return true

-- Simplified approach: check rectangles on-demand with cached red tiles
def maxValidRectangleArea (points : List Point) : Nat :=
  let redTiles := points.toArray
  -- Create HashSet of red tiles for fast lookup
  let redSet := redTiles.foldl (fun s p => s.insert (p.x, p.y)) (Std.HashSet.empty : Std.HashSet (Nat × Nat))

  -- For each pair of red tiles, check if rectangle is valid
  let pairs := points.flatMap fun p1 =>
    points.filterMap fun p2 =>
      if p1 != p2 && isValidRectangleOpt p1 p2 redTiles redSet then
        some (rectangleArea p1 p2)
      else
        none
  pairs.foldl Nat.max 0

-- Part 2
def part2 (input : String) : String :=
  let points := parseInput input
  toString (maxValidRectangleArea points)

end AoC2025.Day09
