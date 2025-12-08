/-
  # Common utilities for Advent of Code 2025
-/
namespace AoC2025

/-- Read input file for a given day -/
def readInput (day : Nat) : IO String := do
  let dayStr := if day < 10 then s!"0{day}" else s!"{day}"
  IO.FS.readFile s!"data/day{dayStr}.txt"

/-- Split string into lines, removing empty trailing lines -/
def lines (s : String) : List String :=
  s.splitOn "\n" |>.reverse |>.dropWhile (·.isEmpty) |>.reverse

/-- Parse a string as a natural number -/
def parseNat? (s : String) : Option Nat :=
  s.trim.toNat?

/-- Parse a string as an integer -/
def parseInt? (s : String) : Option Int :=
  s.trim.toInt?

/-! ## Union-Find (Disjoint Set Union) Data Structure -/

/-- Union-Find data structure for tracking disjoint sets -/
structure UnionFind where
  parent : Array Nat  -- parent[i] is parent of i
  size : Array Nat    -- size[i] is size of component containing root i
  deriving Repr

namespace UnionFind

/-- Initialize union-find with n isolated components -/
def init (n : Nat) : UnionFind :=
  ⟨Array.range n, Array.replicate n 1⟩

/-- Find root of component containing i, with path compression -/
partial def find (uf : UnionFind) (i : Nat) : Nat × UnionFind :=
  if h : i < uf.parent.size then
    let p := uf.parent[i]
    if p == i then
      (i, uf)  -- i is root
    else
      let (root, uf') := uf.find p
      -- Path compression: make i point directly to root
      (root, { uf' with parent := uf'.parent.set! i root })
  else
    (i, uf)  -- out of bounds, shouldn't happen

/-- Union two components; return true if they were separate -/
def union (uf : UnionFind) (i j : Nat) : Bool × UnionFind :=
  let (ri, uf1) := uf.find i
  let (rj, uf2) := uf1.find j
  if ri == rj then
    (false, uf2)  -- already in same component
  else
    -- Union by size: attach smaller to larger
    let si := uf2.size[ri]!
    let sj := uf2.size[rj]!
    if si >= sj then
      let uf3 := { uf2 with
        parent := uf2.parent.set! rj ri,
        size := uf2.size.set! ri (si + sj)
      }
      (true, uf3)
    else
      let uf3 := { uf2 with
        parent := uf2.parent.set! ri rj,
        size := uf2.size.set! rj (si + sj)
      }
      (true, uf3)

/-- Get sizes of all components (returns size for each root) -/
def componentSizes (uf : UnionFind) : List Nat := Id.run do
  let mut sizes : List Nat := []
  let mut uf' := uf
  for i in [:uf'.parent.size] do
    let (root, uf'') := uf'.find i
    uf' := uf''
    if root == i then
      sizes := uf'.size[i]! :: sizes
  return sizes

/-! ### UnionFind Specification Theorems -/

/-- Initial UnionFind has all elements as their own parent -/
theorem init_parent_self (n : Nat) (i : Nat) (h : i < n) :
    (init n).parent[i]'(by simp [init]; exact h) = i := by
  simp [init, Array.range]

/-- Initial UnionFind has all components of size 1 -/
theorem init_size_one (n : Nat) (i : Nat) (h : i < n) :
    (init n).size[i]'(by simp [init]; exact h) = 1 := by
  simp [init]

/-- find returns a valid index within bounds -/
theorem find_result_valid (uf : UnionFind) (i : Nat) :
    i < uf.parent.size →
    let (root, _) := uf.find i
    root < uf.parent.size := by
  sorry

/-- find is idempotent: finding the root of a root gives the same root -/
theorem find_idempotent (uf : UnionFind) (i : Nat) :
    i < uf.parent.size →
    let (root, uf') := uf.find i
    let (root', _) := uf'.find root
    root = root' := by
  sorry

/-- union preserves the parent array size -/
theorem union_preserves_size (uf : UnionFind) (i j : Nat) :
    let (_, uf') := uf.union i j
    uf'.parent.size = uf.parent.size := by
  sorry

/-- union of same element is no-op -/
theorem union_self (uf : UnionFind) (i : Nat) :
    let (wasUnion, uf') := uf.union i i
    wasUnion = false := by
  sorry

/-- componentSizes returns sizes for each root -/
theorem componentSizes_length (uf : UnionFind) :
    (uf.componentSizes).length ≤ uf.parent.size := by
  sorry

end UnionFind

end AoC2025
