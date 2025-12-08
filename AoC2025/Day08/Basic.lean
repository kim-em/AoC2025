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

/-- Union-Find data structure for tracking circuits -/
structure UnionFind where
  parent : Array Nat  -- parent[i] is parent of i
  size : Array Nat    -- size[i] is size of component containing root i
  deriving Repr

/-- Initialize union-find with n isolated components -/
def UnionFind.init (n : Nat) : UnionFind :=
  ⟨Array.range n, Array.mkArray n 1⟩

/-- Find root of component containing i, with path compression -/
partial def UnionFind.find (uf : UnionFind) (i : Nat) : Nat × UnionFind :=
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
def UnionFind.union (uf : UnionFind) (i j : Nat) : Bool × UnionFind :=
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
def UnionFind.componentSizes (uf : UnionFind) : List Nat := Id.run do
  let mut sizes : List Nat := []
  let mut uf' := uf
  for i in [:uf'.parent.size] do
    let (root, uf'') := uf'.find i
    uf' := uf''
    if root == i then
      sizes := uf'.size[i]! :: sizes
  return sizes

end AoC2025.Day08
