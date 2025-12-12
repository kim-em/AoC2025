/-
  # Day 12 - Parsing and Data Structures
-/
import AoC2025.Basic

namespace AoC2025.Day12

-- A shape is a list of (row, col) offsets relative to top-left
abbrev Shape := List (Int × Int)

-- A region specification: width, height, counts of each shape needed
structure Region where
  width : Nat
  height : Nat
  shapeCounts : Array Nat
  deriving Repr

-- Parse a shape from its visual representation
def parseShape (lines : List String) : Shape := Id.run do
  let mut result : Shape := []
  let mut row : Int := 0
  for line in lines do
    let mut col : Int := 0
    for c in line.toList do
      if c == '#' then
        result := result ++ [(row, col)]
      col := col + 1
    row := row + 1
  result

-- Generate all rotations and reflections of a shape
def normalizeShape (s : Shape) : Shape :=
  -- Translate to (0,0) origin
  let minRow := s.foldl (fun m (r, _) => min m r) 0
  let minCol := s.foldl (fun m (_, c) => min m c) 0
  let translated := s.map fun (r, c) => (r - minRow, c - minCol)
  -- Sort for canonical form
  translated.mergeSort (fun (r1, c1) (r2, c2) => r1 < r2 || (r1 == r2 && c1 < c2))

def rotate90 (s : Shape) : Shape :=
  -- (r, c) -> (c, -r)
  normalizeShape (s.map fun (r, c) => (c, -r))

def flipH (s : Shape) : Shape :=
  -- (r, c) -> (r, -c)
  normalizeShape (s.map fun (r, c) => (r, -c))

-- Generate all 8 orientations (4 rotations × 2 flips)
def allOrientations (s : Shape) : List Shape :=
  let s0 := normalizeShape s
  let s1 := rotate90 s0
  let s2 := rotate90 s1
  let s3 := rotate90 s2
  let rotations := [s0, s1, s2, s3]
  let flipped := rotations.map flipH
  (rotations ++ flipped).eraseDups

-- Check if a string contains a substring
def String.containsSub (s sub : String) : Bool :=
  (s.splitOn sub).length > 1

-- Parse the input file
def parseInput (input : String) : Array (List Shape) × Array Region := Id.run do
  let lines := input.splitOn "\n"
  -- First parse shapes
  let mut shapes : Array (List Shape) := #[]
  let mut i := 0
  let mut currentShapeLines : List String := []
  let mut parsingShapes := true

  while i < lines.length do
    let line := lines[i]!
    if line.isEmpty then
      if !currentShapeLines.isEmpty then
        let shape := parseShape currentShapeLines.reverse
        shapes := shapes.push (allOrientations shape)
        currentShapeLines := []
      i := i + 1
      continue
    if String.containsSub line "x" && line.any Char.isDigit && String.containsSub line ":" then
      -- This is a region line
      parsingShapes := false
      if !currentShapeLines.isEmpty then
        let shape := parseShape currentShapeLines.reverse
        shapes := shapes.push (allOrientations shape)
        currentShapeLines := []
      break
    if parsingShapes then
      if String.containsSub line ":" && (line.take 2).any Char.isDigit then
        -- New shape header like "0:"
        if !currentShapeLines.isEmpty then
          let shape := parseShape currentShapeLines.reverse
          shapes := shapes.push (allOrientations shape)
          currentShapeLines := []
      else
        currentShapeLines := line :: currentShapeLines
    i := i + 1

  -- Now parse regions
  let mut regions : Array Region := #[]
  while i < lines.length do
    let line := lines[i]!
    if !line.isEmpty && String.containsSub line "x" then
      -- Parse "WxH: c1 c2 c3 ..."
      let parts := line.splitOn ":"
      if parts.length >= 2 then
        let dims := parts[0]!.splitOn "x"
        if dims.length >= 2 then
          let w := dims[0]!.trim.toNat!
          let h := dims[1]!.trim.toNat!
          let counts := parts[1]!.trim.splitOn " "
            |>.filter (·.length > 0)
            |>.map String.toNat!
          regions := regions.push { width := w, height := h, shapeCounts := counts.toArray }
    i := i + 1

  (shapes, regions)

end AoC2025.Day12
