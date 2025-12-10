-- Test script for Day 9 Part 2
import AoC2025.Day09

open AoC2025.Day09

def exampleInput := "7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3"

#eval do
  let points := parseInput exampleInput
  IO.println s!"Parsed {points.length} points"
  for p in points do
    IO.println s!"  ({p.x}, {p.y})"

  -- Test part 1
  let p1 := maxRectangleArea points
  IO.println s!"Part 1: {p1}"  -- Should be 50

  -- Test part 2
  let p2 := maxValidRectangleArea points
  IO.println s!"Part 2: {p2}"  -- Should be 24

-- Test specific point-in-polygon cases
def vertices := #[
  { x := 7, y := 1 : Point },
  { x := 11, y := 1 : Point },
  { x := 11, y := 7 : Point },
  { x := 9, y := 7 : Point },
  { x := 9, y := 5 : Point },
  { x := 2, y := 5 : Point },
  { x := 2, y := 3 : Point },
  { x := 7, y := 3 : Point }
]

-- Test points that should be inside (green):
-- (8, 4) should be inside
-- (3, 4) should be inside
-- Test points that should be outside:
-- (1, 1) should be outside
-- (5, 6) should be outside

#eval do
  IO.println "Testing point-in-polygon:"
  IO.println s!"(8,4) inside: {isInsidePolygon { x := 8, y := 4 } vertices}"  -- Should be true
  IO.println s!"(3,4) inside: {isInsidePolygon { x := 3, y := 4 } vertices}"  -- Should be true
  IO.println s!"(10,4) inside: {isInsidePolygon { x := 10, y := 4 } vertices}"  -- Should be true
  IO.println s!"(1,1) inside: {isInsidePolygon { x := 1, y := 1 } vertices}"  -- Should be false
  IO.println s!"(5,6) inside: {isInsidePolygon { x := 5, y := 6 } vertices}"  -- Should be false
  IO.println s!"(6,2) inside: {isInsidePolygon { x := 6, y := 2 } vertices}"  -- Should be false

-- Test on-perimeter detection
#eval do
  let redSet : Std.HashSet (Nat × Nat) := vertices.foldl (fun s (p : Point) => s.insert (p.x, p.y)) {}
  IO.println "Testing isGreenOrRed:"
  IO.println s!"(8,1) greenOrRed: {isGreenOrRed { x := 8, y := 1 } vertices redSet}"  -- On perimeter, should be true
  IO.println s!"(9,1) greenOrRed: {isGreenOrRed { x := 9, y := 1 } vertices redSet}"  -- On perimeter, should be true
  IO.println s!"(11,4) greenOrRed: {isGreenOrRed { x := 11, y := 4 } vertices redSet}"  -- On perimeter, should be true

  -- Test points that should be OUTSIDE:
  IO.println ""
  IO.println "Testing points that should be OUTSIDE:"
  IO.println s!"(2,1) greenOrRed: {isGreenOrRed { x := 2, y := 1 } vertices redSet}"  -- Outside, should be false
  IO.println s!"(2,2) greenOrRed: {isGreenOrRed { x := 2, y := 2 } vertices redSet}"  -- Outside, should be false
  IO.println s!"(5,1) greenOrRed: {isGreenOrRed { x := 5, y := 1 } vertices redSet}"  -- Outside, should be false
  IO.println s!"(5,2) greenOrRed: {isGreenOrRed { x := 5, y := 2 } vertices redSet}"  -- Outside, should be false

  -- Test the rectangle from (2,5) to (11,1) which should be INVALID for Part 2
  IO.println ""
  IO.println "Testing segment validity for rectangle (2,5) to (11,1):"
  IO.println s!"  Segment y=1, x=[2,11]: valid={isHorizontalSegmentValid 1 2 11 vertices redSet}"  -- Should be false
  IO.println s!"  Segment y=2, x=[2,11]: valid={isHorizontalSegmentValid 2 2 11 vertices redSet}"
  IO.println s!"  Segment y=3, x=[2,11]: valid={isHorizontalSegmentValid 3 2 11 vertices redSet}"
  IO.println s!"  Segment y=4, x=[2,11]: valid={isHorizontalSegmentValid 4 2 11 vertices redSet}"
  IO.println s!"  Segment y=5, x=[2,11]: valid={isHorizontalSegmentValid 5 2 11 vertices redSet}"
