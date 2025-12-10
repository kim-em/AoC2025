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
-- Uses Int arithmetic to avoid Nat underflow issues
def isInsidePolygon (p : Point) (vertices : Array Point) : Bool := Id.run do
  let n := vertices.size
  let mut inside := false
  let mut j := n - 1
  let px : Int := p.x
  let py : Int := p.y
  for i in [0:n] do
    let vi := vertices[i]!
    let vj := vertices[j]!
    let vix : Int := vi.x
    let viy : Int := vi.y
    let vjx : Int := vj.x
    let vjy : Int := vj.y
    if ((viy > py) != (vjy > py)) &&
       (px < (vjx - vix) * (py - viy) / (vjy - viy) + vix) then
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

-- Get unique y-coordinates where something interesting happens (polygon vertices)
def getSignificantYs (vertices : Array Point) (minY maxY : Nat) : Array Nat := Id.run do
  let mut ys : Std.HashSet Nat := {}
  -- Add all vertex y-coordinates
  for v in vertices do
    if minY <= v.y && v.y <= maxY then
      ys := ys.insert v.y
  -- Add minY and maxY
  ys := ys.insert minY
  ys := ys.insert maxY
  -- Convert to sorted array
  let arr := ys.toArray.qsort (· < ·)
  return arr

-- Check if ALL points in horizontal segment at y from minX to maxX are valid
-- Uses the fact that validity changes only at polygon edges
def isHorizontalSegmentValid (y : Nat) (minX maxX : Nat) (vertices : Array Point) (redSet : Std.HashSet (Nat × Nat)) : Bool := Id.run do
  -- Get all x-coordinates where edges cross this y level
  let n := vertices.size
  let mut edgeXs : Array Nat := #[]

  for i in [0:n] do
    let v1 := vertices[i]!
    let v2 := vertices[(i + 1) % n]!

    -- Horizontal edge at this y
    if v1.y == y && v2.y == y then
      edgeXs := edgeXs.push (min v1.x v2.x)
      edgeXs := edgeXs.push (max v1.x v2.x)
    -- Vertical edge crossing this y
    else if v1.x == v2.x then
      let minY' := min v1.y v2.y
      let maxY' := max v1.y v2.y
      if minY' <= y && y <= maxY' then
        edgeXs := edgeXs.push v1.x

  -- Sort and deduplicate
  let sorted := edgeXs.qsort (· < ·)
  let mut uniqueXs : Array Nat := #[]
  for x in sorted do
    if uniqueXs.isEmpty || uniqueXs.back! != x then
      uniqueXs := uniqueXs.push x

  -- Filter to range [minX, maxX]
  let relevantXs := uniqueXs.filter (fun x => minX <= x && x <= maxX)

  -- Check all relevant edge crossing points
  for x in relevantXs do
    if !isGreenOrRed { x, y } vertices redSet then
      return false

  -- Check midpoint between each consecutive pair (including endpoints)
  let mut checkPoints : Array Nat := #[minX]
  for x in relevantXs do
    if minX < x && x < maxX then
      checkPoints := checkPoints.push x
  checkPoints := checkPoints.push maxX

  -- Deduplicate checkPoints
  let mut uniqueCheckPoints : Array Nat := #[]
  for x in checkPoints do
    if uniqueCheckPoints.isEmpty || uniqueCheckPoints.back! != x then
      uniqueCheckPoints := uniqueCheckPoints.push x

  for i in [0:uniqueCheckPoints.size - 1] do
    let left := uniqueCheckPoints[i]!
    let right := uniqueCheckPoints[i + 1]!
    -- Check midpoint
    let mid := (left + right) / 2
    if !isGreenOrRed { x := mid, y } vertices redSet then
      return false

  return true

-- Main function - optimized version
def maxValidRectangleArea (points : List Point) : Nat := Id.run do
  let vertices := points.toArray
  let redSet := vertices.foldl (fun s p => s.insert (p.x, p.y)) (Std.HashSet.emptyWithCapacity 500)

  let mut maxArea := 0

  -- Check all pairs of red tiles
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

        -- Skip degenerate rectangles and rectangles smaller than current best
        if width > 1 && height > 1 && area > maxArea then
          -- Quick check: all 4 corners must be valid
          let corner1Valid := redSet.contains (p1.x, p1.y)
          let corner2Valid := redSet.contains (p2.x, p2.y)
          let corner3Valid := isGreenOrRed { x := minX, y := maxY } vertices redSet
          let corner4Valid := isGreenOrRed { x := maxX, y := minY } vertices redSet

          if corner1Valid && corner2Valid && corner3Valid && corner4Valid then
            -- Get significant y-coordinates to check
            let sigYs := getSignificantYs vertices minY maxY
            let mut allValid := true

            -- For each y-level, check the horizontal segment
            -- Only need to check: boundary y's and midpoints between them
            let mut yToCheck : Array Nat := #[]

            -- Add all significant ys
            for y in sigYs do
              yToCheck := yToCheck.push y

            -- Also add midpoints between consecutive significant ys
            for i in [0:sigYs.size - 1] do
              let y1 := sigYs[i]!
              let y2 := sigYs[i + 1]!
              if y2 > y1 + 1 then
                yToCheck := yToCheck.push ((y1 + y2) / 2)

            -- Sort and deduplicate
            let sortedY := yToCheck.qsort (· < ·)

            for y in sortedY do
              if allValid && !isHorizontalSegmentValid y minX maxX vertices redSet then
                allValid := false

            if allValid then
              maxArea := area

  return maxArea

-- Part 2
def part2 (input : String) : String :=
  let points := parseInput input
  let area := maxValidRectangleArea points
  toString area

-- ============ Specification Theorems ============

-- Rectangle area is always at least 1
theorem rectangleArea_ge_one (p1 p2 : Point) : rectangleArea p1 p2 ≥ 1 := by
  sorry

-- Rectangle area is symmetric
theorem rectangleArea_comm (p1 p2 : Point) : rectangleArea p1 p2 = rectangleArea p2 p1 := by
  sorry

-- isOnSegment excludes endpoints
theorem isOnSegment_not_endpoint_left (p a b : Point) (h : isOnSegment p a b = true) : p ≠ a := by
  sorry

theorem isOnSegment_not_endpoint_right (p a b : Point) (h : isOnSegment p a b = true) : p ≠ b := by
  sorry

-- isOnSegment only works for axis-aligned segments
-- (for non-axis-aligned, always returns false)
theorem isOnSegment_non_axis_aligned (p a b : Point)
    (hx : a.x ≠ b.x) (hy : a.y ≠ b.y) : isOnSegment p a b = false := by
  sorry

-- getSignificantYs contains the boundary values
theorem getSignificantYs_contains_minY (vertices : Array Point) (minY maxY : Nat) :
    minY ∈ (getSignificantYs vertices minY maxY).toList := by
  sorry

theorem getSignificantYs_contains_maxY (vertices : Array Point) (minY maxY : Nat) :
    maxY ∈ (getSignificantYs vertices minY maxY).toList := by
  sorry

end AoC2025.Day09
