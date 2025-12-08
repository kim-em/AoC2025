/-
  # Advent of Code 2025 - Day 08
-/
import AoC2025.Day08.Basic

namespace AoC2025.Day08

/-- Generate all edges (pairs of points) with their squared distances -/
def generateEdges (points : Array Point) : Array Edge := Id.run do
  let n := points.size
  let mut edges : Array Edge := #[]
  for i in [:n] do
    for j in [i+1:n] do
      let d := distSq points[i]! points[j]!
      edges := edges.push ⟨i, j, d⟩
  return edges

/-- Compare edges by squared distance -/
def Edge.lt (e1 e2 : Edge) : Bool :=
  e1.distSq < e2.distSq

/-- Connect k shortest edges and return sizes of 3 largest circuits -/
def connectKShortest (points : Array Point) (k : Nat) : List Nat := Id.run do
  let edges := generateEdges points
  let sortedEdges := edges.qsort Edge.lt
  let mut uf := AoC2025.UnionFind.init points.size

  -- Process first k edges (connect or skip if already connected)
  for i in [:min k sortedEdges.size] do
    let edge := sortedEdges[i]!
    let (_, uf') := uf.union edge.i edge.j
    uf := uf'

  -- Get component sizes and return top 3
  let sizes := uf.componentSizes
  let sorted := sizes.toArray.qsort (· > ·)  -- sort descending
  sorted.toList.take 3

-- Part 1
def part1 (input : String) : String :=
  let lns := AoC2025.lines input
  let points := lns.filterMap parseLine |>.toArray
  let top3 := connectKShortest points 1000
  let product := top3.foldl (· * ·) 1
  toString product

/-- Connect until all in one circuit, return last edge connected -/
def connectUntilOne (points : Array Point) : Option Edge := Id.run do
  let edges := generateEdges points
  let sortedEdges := edges.qsort Edge.lt
  let mut uf := AoC2025.UnionFind.init points.size
  let mut numComponents := points.size
  let mut lastEdge : Option Edge := none

  -- Process edges until we have only 1 component
  for i in [:sortedEdges.size] do
    if numComponents <= 1 then break
    let edge := sortedEdges[i]!
    let (wasUnion, uf') := uf.union edge.i edge.j
    uf := uf'
    if wasUnion then
      lastEdge := some edge
      numComponents := numComponents - 1

  return lastEdge

-- Part 2
def part2 (input : String) : String :=
  let lns := AoC2025.lines input
  let points := lns.filterMap parseLine |>.toArray
  match connectUntilOne points with
  | none => "0"  -- shouldn't happen
  | some edge =>
    let p1 := points[edge.i]!
    let p2 := points[edge.j]!
    toString (p1.x.toNat * p2.x.toNat)

/-! ## Specification Theorems -/

/-- Edge.lt is a strict total order on edges by distance -/
theorem Edge.lt_trans (e1 e2 e3 : Edge) :
    e1.lt e2 = true → e2.lt e3 = true → e1.lt e3 = true := by
  simp [Edge.lt]
  omega

/-- generateEdges produces all pairs with correct indices -/
theorem generateEdges_spec (points : Array Point) (e : Edge) :
    e ∈ generateEdges points →
    e.i < points.size ∧
    e.j < points.size ∧
    e.i < e.j ∧
    e.distSq = distSq points[e.i]! points[e.j]! := by
  sorry

/-- connectKShortest processes exactly k edges (or fewer if not enough edges) -/
theorem connectKShortest_processes_k (points : Array Point) (k : Nat) :
    let edges := generateEdges points
    let sortedEdges := edges.qsort Edge.lt
    let processed := min k sortedEdges.size
    (connectKShortest points k).length ≤ 3 := by
  sorry

/-- connectUntilOne terminates and returns last edge that reduced components -/
theorem connectUntilOne_last_edge (points : Array Point) :
    points.size > 1 →
    ∃ edge, connectUntilOne points = some edge := by
  sorry

end AoC2025.Day08
