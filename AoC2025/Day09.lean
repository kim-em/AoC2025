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

-- Scanline approach: for each y-coordinate, compute the valid x-intervals
-- A point (x, y) is valid if it's red, on perimeter, or inside the polygon

-- For a given y, find all x-values where vertical polygon edges cross this y
-- Returns sorted array of (x, isOpening) pairs
def findVerticalEdgeCrossings (y : Nat) (vertices : Array Point) : Array Nat := Id.run do
  let n := vertices.size
  let mut crossings : Array Nat := #[]
  for i in [0:n] do
    let v1 := vertices[i]!
    let v2 := vertices[(i + 1) % n]!
    -- Check if this is a vertical edge that STRICTLY spans y (not just touches)
    if v1.x == v2.x then
      let minY := min v1.y v2.y
      let maxY := max v1.y v2.y
      -- Only count if y is strictly between the endpoints (for inside calculation)
      -- For y at an endpoint, we need to be careful about double counting
      if minY < y && y < maxY then
        crossings := crossings.push v1.x
  return crossings.qsort (· < ·)

-- For a given y, compute the intervals of x that are "inside" the polygon
-- Returns array of (start, end) pairs representing closed intervals
def computeInsideIntervalsAtY (y : Nat) (vertices : Array Point) : Array (Nat × Nat) := Id.run do
  let crossings := findVerticalEdgeCrossings y vertices
  let mut intervals : Array (Nat × Nat) := #[]
  -- Pair up crossings: first is opening, second is closing
  let mut i := 0
  while i + 1 < crossings.size do
    -- After odd number of crossings from left, we're inside
    intervals := intervals.push (crossings[i]!, crossings[i+1]!)
    i := i + 2
  return intervals

-- Find all x-coordinates where polygon has a vertical edge at y (edge spans y)
-- and also horizontal edges at y (edge is at y)
def findEdgeCrossingsAtY (y : Nat) (vertices : Array Point) : Array Nat := Id.run do
  let n := vertices.size
  let mut crossings : Array Nat := #[]
  for i in [0:n] do
    let v1 := vertices[i]!
    let v2 := vertices[(i + 1) % n]!
    -- Vertical edge spanning y
    if v1.x == v2.x then
      let minY := min v1.y v2.y
      let maxY := max v1.y v2.y
      if minY <= y && y <= maxY then
        crossings := crossings.push v1.x
    -- Horizontal edge at y
    else if v1.y == y && v2.y == y then
      crossings := crossings.push (min v1.x v2.x)
      crossings := crossings.push (max v1.x v2.x)
  -- Remove duplicates from sorted array
  let sorted := crossings.qsort (· < ·)
  let mut result : Array Nat := #[]
  for x in sorted do
    if result.isEmpty || result.back! != x then
      result := result.push x
  return result

-- Check if the horizontal segment [minX, maxX] at height y is entirely valid
-- Uses polygon structure: check transition points and midpoints of segments
def isRowValidFast (y : Nat) (minX maxX : Nat) (vertices : Array Point) (redSet : Std.HashSet (Nat × Nat)) : Bool := Id.run do
  -- Check endpoints first
  if !isGreenOrRed { x := minX, y } vertices redSet then return false
  if !isGreenOrRed { x := maxX, y } vertices redSet then return false

  -- Find all edge crossings at this y
  let crossings := findEdgeCrossingsAtY y vertices

  -- Filter crossings to those within our range
  let relevantCrossings := crossings.filter (fun cx => minX < cx && cx < maxX)

  -- Check each relevant crossing point
  for cx in relevantCrossings do
    if !isGreenOrRed { x := cx, y } vertices redSet then
      return false

  -- Check midpoint of each segment between consecutive points
  let mut checkPoints : Array Nat := #[minX]
  for cx in relevantCrossings do
    checkPoints := checkPoints.push cx
  checkPoints := checkPoints.push maxX

  for i in [0:checkPoints.size - 1] do
    let left := checkPoints[i]!
    let right := checkPoints[i + 1]!
    if right > left + 1 then
      let mid := (left + right) / 2
      if !isGreenOrRed { x := mid, y } vertices redSet then
        return false

  return true

-- Optimized rectangle validation
def isValidRectangleFast (p1 p2 : Point) (vertices : Array Point) (redSet : Std.HashSet (Nat × Nat)) : Bool := Id.run do
  let minX := min p1.x p2.x
  let maxX := max p1.x p2.x
  let minY := min p1.y p2.y
  let maxY := max p1.y p2.y

  -- Check corners are red
  if !redSet.contains (p1.x, p1.y) || !redSet.contains (p2.x, p2.y) then
    return false

  -- For efficiency, first check the four corners (two are red, two need validation)
  -- Other two corners
  if !isGreenOrRed { x := minX, y := maxY } vertices redSet then return false
  if !isGreenOrRed { x := maxX, y := minY } vertices redSet then return false

  -- Check each row in the rectangle
  for y in [minY:maxY+1] do
    if !isRowValidFast y minX maxX vertices redSet then
      return false

  return true

-- Brute force validation - check every point
def isValidRectangleBruteForce (p1 p2 : Point) (vertices : Array Point) (redSet : Std.HashSet (Nat × Nat)) : Bool := Id.run do
  let minX := min p1.x p2.x
  let maxX := max p1.x p2.x
  let minY := min p1.y p2.y
  let maxY := max p1.y p2.y

  -- Check corners are red
  if !redSet.contains (p1.x, p1.y) || !redSet.contains (p2.x, p2.y) then
    return false

  -- Check all points in rectangle are green or red
  for y in [minY:maxY+1] do
    for x in [minX:maxX+1] do
      if !isGreenOrRed { x, y } vertices redSet then
        return false

  return true

-- Check if a point is valid (green or red) using only the information we have
-- For a rectilinear polygon, a point is green if:
-- 1. It's a red tile (vertex)
-- 2. It's on an edge between vertices
-- 3. It's inside the polygon
def isValidPoint (p : Point) (vertices : Array Point) (redSet : Std.HashSet (Nat × Nat)) : Bool :=
  isGreenOrRed p vertices redSet

-- For a rectangle to be valid, all points on its boundary AND interior must be valid
-- But we can't check all points. Instead, we use the polygon structure:
-- A rectangle is valid iff:
-- 1. All four corners are valid (at least two must be red)
-- 2. For each row y in [minY, maxY], the segment [minX, maxX] is entirely valid
--
-- A horizontal segment is entirely valid iff the polygon boundary doesn't
-- cross it in an "invalid" region (i.e., crossing from inside to outside)

-- Get unique y-coordinates where something interesting happens
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
    if !isValidPoint { x, y } vertices redSet then
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
    if !isValidPoint { x := mid, y } vertices redSet then
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
          let corner3Valid := isValidPoint { x := minX, y := maxY } vertices redSet
          let corner4Valid := isValidPoint { x := maxX, y := minY } vertices redSet

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

end AoC2025.Day09
