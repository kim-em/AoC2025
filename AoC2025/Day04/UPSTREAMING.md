# Day 04 Upstream Candidates

## Potential Contributions

### 1. Grid Accessibility / Cellular Automaton Patterns

The accessibility check (fewer than 4 neighbors with property P) is a common pattern in:
- Cellular automata (Conway's Game of Life variants)
- Grid-based simulations
- Image processing (erosion/dilation)

**Not recommended for upstream**: Too problem-specific. The general pattern
(counting neighbors satisfying predicate) is standard and likely exists.

### 2. Termination Proof for Grid Fixpoint

**Pattern**: Repeatedly apply transformation until fixpoint, where each step
removes at least one element.

**Location**: `removeAllAccessible` with `countRolls` as termination measure

**Why interesting**: Common pattern for cellular automata fixpoint computation.
Could be generalized to a theorem:
```lean
theorem fixpoint_terminates (f : Grid → Grid) (measure : Grid → Nat)
    (h : ∀ g, f g ≠ g → measure (f g) < measure g) :
    ∃ n, f^[n] g = f^[n+1] g
```

**Assessment**: Medium interest - the termination pattern is general but proving
it for specific grid operations requires domain-specific lemmas.

## Assessment

- **Accessibility pattern**: Not recommended (too specific)
- **Fixpoint termination**: Medium priority - useful pattern but needs generalization
