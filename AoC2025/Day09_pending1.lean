/-
  # Day 09 - isOnSegment_not_endpoint_left theorem for Aristotle
-/
import Mathlib

namespace AoC2025.Day09

structure Point where
  x : Nat
  y : Nat
  deriving Repr, BEq, Inhabited

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

-- isOnSegment excludes endpoints
theorem isOnSegment_not_endpoint_left (p a b : Point) (h : isOnSegment p a b = true) : p ≠ a := by
  sorry

-- Keep this as admit so Aristotle focuses on the above
theorem isOnSegment_not_endpoint_right (p a b : Point) (h : isOnSegment p a b = true) : p ≠ b := by
  admit

end AoC2025.Day09
