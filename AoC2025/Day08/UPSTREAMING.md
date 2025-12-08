# Day 08 - Upstream Candidates

## UnionFind Data Structure

**Location**: Refactored to `AoC2025/Basic.lean` (lines 23-84)

**What**: Complete union-find (disjoint set union) implementation with:
- Path compression in `find`
- Union by size
- Component size tracking
- Functional API (returns modified structure)

**Why upstream to Mathlib**:
- Fundamental data structure for graph algorithms (MST, connectivity)
- Efficient implementation with path compression and union by size
- Currently Mathlib lacks a union-find structure
- Useful for: graph theory, equivalence relations, Kruskal's algorithm
- Specification theorems provide correctness guarantees

**Generalization needed**:
- Currently uses `Nat` indices; could be generalized to `Fin n`
- Could add more sophisticated API (connected?, num_components, etc.)
- Formal proofs of amortized complexity bounds
- Integration with Mathlib's graph theory library

## 3D Point and Distance

**Location**: `AoC2025/Day08/Basic.lean` (lines 8-30)

**What**: 3D integer point structure and squared Euclidean distance

**Why NOT upstream**:
- Too specific; Mathlib already has comprehensive geometry in `Mathlib.Geometry.Euclidean.*`
- Integer-specific when Mathlib prefers generality
- AoC-specific parsing logic mixed with geometry

## Edge Structures and MST Algorithm

**Location**: `AoC2025/Day08.lean`

**What**: Edge representation and Kruskal's MST-style algorithm

**Why NOT upstream** (currently):
- Implementation uses imperative loops and mutation
- Would need significant refactoring to Mathlib style
- Once UnionFind is upstreamed, could build MST on top of it
- Current form is application code, not library code
