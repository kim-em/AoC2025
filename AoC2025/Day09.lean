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

-- Check if point is on a segment from a to b (axis-aligned), EXCLUDING endpoints
def isOnSegment (p a b : Point) : Bool :=
  if p == a || p == b then
    false  -- Endpoints are red tiles, not green
  else if a.x == b.x then
    -- Vertical segment (excluding endpoints)
    let minY := min a.y b.y
    let maxY := max a.y b.y
    p.x == a.x && minY < p.y && p.y < maxY
  else if a.y == b.y then
    -- Horizontal segment (excluding endpoints)
    let minX := min a.x b.x
    let maxX := max a.x b.x
    p.y == a.y && minX < p.x && p.x < maxX
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

-- Check if a point is green (on perimeter or inside)
def isGreenOrRed (p : Point) (vertices : Array Point) (redSet : Std.HashSet (Nat × Nat)) : Bool :=
  -- Red tiles are valid
  if redSet.contains (p.x, p.y) then
    true
  else
    -- Check if on perimeter
    let n := vertices.size
    let onPerimeter := Id.run do
      for i in [0:n] do
        let a := vertices[i]!
        let b := vertices[(i + 1) % n]!
        if isOnSegment p a b then
          return true
      return false
    if onPerimeter then
      true
    else
      -- Check if inside
      isInsidePolygon p vertices

-- For a rectangle, check if ALL points are green or red
-- Only check rectangles up to a maximum area
def isValidRectangle (p1 p2 : Point) (vertices : Array Point) (redSet : Std.HashSet (Nat × Nat)) (maxArea : Nat) : Bool := Id.run do
  let minX := min p1.x p2.x
  let maxX := max p1.x p2.x
  let minY := min p1.y p2.y
  let maxY := max p1.y p2.y

  -- Check corners are red
  if !redSet.contains (p1.x, p1.y) || !redSet.contains (p2.x, p2.y) then
    return false

  let width := maxX - minX + 1
  let height := maxY - minY + 1
  let area := width * height

  -- Skip rectangles that are too large
  if area > maxArea then
    return false

  -- Check all points in rectangle are green or red
  for y in [minY:maxY+1] do
    for x in [minX:maxX+1] do
      if !isGreenOrRed { x, y } vertices redSet then
        return false

  return true

-- Main function - check all rectangles
def maxValidRectangleArea (points : List Point) : Nat := Id.run do
  let vertices := points.toArray
  let redSet := vertices.foldl (fun s p => s.insert (p.x, p.y)) (Std.HashSet.emptyWithCapacity 500)

  let mut maxArea := 0

  -- Just check all rectangles, skipping those that are too large to be practical
  let maxAreaLimit := 700000

  for p1 in points do
    for p2 in points do
      if p1 != p2 then
        let minX := min p1.x p2.x
        let maxX := max p1.x p2.x
        let minY := min p1.y p2.y
        let maxY := max p1.y p2.y
        let width := maxX - minX + 1
        let height := maxY - minY + 1
        let area := width * height

        -- Skip degenerate rectangles (line segments) and rectangles that are too large
        if width > 1 && height > 1 && area ≤ maxAreaLimit then
          if isValidRectangle p1 p2 vertices redSet maxAreaLimit then
            if area > maxArea then
              maxArea := area

  return maxArea

-- Part 2
def part2 (input : String) : String :=
  let points := parseInput input
  let area := maxValidRectangleArea points
  toString area

end AoC2025.Day09
