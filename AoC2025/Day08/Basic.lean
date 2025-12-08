/-
  # Day 08 - Parsing and Data Structures
-/
import AoC2025.Basic

namespace AoC2025.Day08

/-- A point in 3D space -/
structure Point where
  x : Int
  y : Int
  z : Int
  deriving Repr, BEq, Inhabited

/-- Parse a line like "162,817,812" into a Point -/
def parseLine (s : String) : Option Point := do
  let parts := s.splitOn ","
  if parts.length != 3 then none
  let x ← parts[0]!.toInt?
  let y ← parts[1]!.toInt?
  let z ← parts[2]!.toInt?
  some ⟨x, y, z⟩

/-- Squared Euclidean distance between two points -/
def distSq (p1 p2 : Point) : Int :=
  let dx := p1.x - p2.x
  let dy := p1.y - p2.y
  let dz := p1.z - p2.z
  dx * dx + dy * dy + dz * dz

/-- An edge between two junction boxes (indices in the point array) -/
structure Edge where
  i : Nat
  j : Nat
  distSq : Int  -- squared distance
  deriving Repr, Inhabited

end AoC2025.Day08
