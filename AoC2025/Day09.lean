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

-- Cache for memoizing isGreenTile results
structure TileCache where
  redSet : Std.HashSet (Nat × Nat)
  greenCache : IO.Ref (Std.HashSet (Nat × Nat))
  notGreenCache : IO.Ref (Std.HashSet (Nat × Nat))

-- Check if a point is green with caching
def isGreenTileCached (p : Point) (redTiles : Array Point) (cache : TileCache) : IO Bool := do
  let pos := (p.x, p.y)

  -- Check if red
  if cache.redSet.contains pos then
    return false  -- Red tiles are not green tiles

  -- Check cache
  let greenCache ← cache.greenCache.get
  if greenCache.contains pos then
    return true

  let notGreenCache ← cache.notGreenCache.get
  if notGreenCache.contains pos then
    return false

  -- Compute and cache
  let isGreen := isGreenTile p redTiles
  if isGreen then
    cache.greenCache.modify (·.insert pos)
  else
    cache.notGreenCache.modify (·.insert pos)
  return isGreen

-- Fast validation: check perimeter + sample interior
def isValidRectangleCached (p1 p2 : Point) (redTiles : Array Point) (cache : TileCache) : IO Bool := do
  let minX := min p1.x p2.x
  let maxX := max p1.x p2.x
  let minY := min p1.y p2.y
  let maxY := max p1.y p2.y

  -- Check corners (must be red)
  if !cache.redSet.contains (p1.x, p1.y) || !cache.redSet.contains (p2.x, p2.y) then
    return false

  let width := maxX - minX + 1
  let height := maxY - minY + 1

  -- Check perimeter only (much faster)
  -- Top and bottom edges
  for x in [minX:maxX+1] do
    for y in [minY, maxY] do
      let pos := (x, y)
      if !cache.redSet.contains pos then
        let isGreen ← isGreenTileCached { x, y } redTiles cache
        if !isGreen then
          return false

  -- Left and right edges (excluding corners we already checked)
  for y in [minY+1:maxY] do
    for x in [minX, maxX] do
      let pos := (x, y)
      if !cache.redSet.contains pos then
        let isGreen ← isGreenTileCached { x, y } redTiles cache
        if !isGreen then
          return false

  -- Sample interior: check center and a few other points
  let samples := [
    (minX + width / 2, minY + height / 2),  -- Center
    (minX + width / 4, minY + height / 4),
    (minX + 3 * width / 4, minY + height / 4),
    (minX + width / 4, minY + 3 * height / 4),
    (minX + 3 * width / 4, minY + 3 * height / 4)
  ]

  for (sx, sy) in samples do
    let pos := (sx, sy)
    if !cache.redSet.contains pos then
      let isGreen ← isGreenTileCached { x := sx, y := sy } redTiles cache
      if !isGreen then
        return false

  return true

-- Main function using cached validation
def maxValidRectangleArea (points : List Point) : IO Nat := do
  let redTiles := points.toArray
  let redSet := redTiles.foldl (fun s p => s.insert (p.x, p.y)) Std.HashSet.empty

  let cache : TileCache := {
    redSet := redSet,
    greenCache := ← IO.mkRef Std.HashSet.empty,
    notGreenCache := ← IO.mkRef Std.HashSet.empty
  }

  IO.println s!"Checking {points.length * points.length} rectangle pairs..."
  let mut maxArea := 0
  let mut count := 0
  for p1 in points do
    for p2 in points do
      if p1 != p2 then
        count := count + 1
        if count % 10000 == 0 then
          IO.println s!"Checked {count} pairs, maxArea so far: {maxArea}"
        let valid ← isValidRectangleCached p1 p2 redTiles cache
        if valid then
          let area := rectangleArea p1 p2
          if area > maxArea then
            maxArea := area
            IO.println s!"New max: {area} at ({p1.x},{p1.y}) to ({p2.x},{p2.y})"

  return maxArea

-- Part 2
def part2 (input : String) : IO String := do
  let points := parseInput input
  let area ← maxValidRectangleArea points
  return toString area

end AoC2025.Day09
