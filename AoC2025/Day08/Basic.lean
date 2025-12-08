/-
  # Day 08 - Parsing and Data Structures
-/
import AoC2025.Basic
import Mathlib.Tactic.Ring

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

/-! ## Specification Theorems -/

/-- Parsing a valid line produces a Point with matching coordinates -/
theorem parseLine_eq (s : String) (x y z : Int) :
    parseLine s = some ⟨x, y, z⟩ →
    ∃ parts : List String,
      parts = s.splitOn "," ∧
      parts.length = 3 ∧
      parts[0]!.toInt? = some x ∧
      parts[1]!.toInt? = some y ∧
      parts[2]!.toInt? = some z := by
  sorry

/-- distSq is commutative -/
theorem distSq_comm (p1 p2 : Point) : distSq p1 p2 = distSq p2 p1 := by
  simp [distSq]
  ring

/-- distSq is non-negative -/
theorem distSq_nonneg (p1 p2 : Point) : distSq p1 p2 ≥ 0 := by
  sorry

/-- distSq to self is zero -/
theorem distSq_self (p : Point) : distSq p p = 0 := by
  simp [distSq]

end AoC2025.Day08
