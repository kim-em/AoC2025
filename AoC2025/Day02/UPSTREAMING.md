# Day 02 Upstream Candidates

## Potential Contributions

### 1. Geometric Series for Digit Repetition (Mathlib)

**Function**: `repMultiplier d k`
**Location**: `AoC2025/Day02/Basic.lean`

Computes `(10^(d*k) - 1) / (10^d - 1)`, which equals `Σ_{i=0}^{k-1} 10^(d*i)`.

This is useful for:
- Digit manipulation problems
- Representing numbers formed by repeating digit patterns
- Computing positions in decimal expansions

**Example**: `repMultiplier 2 3 = 10101` (so `12` repeated 3 times = `12 * 10101 = 121212`)

**Why useful**: General digit-pattern arithmetic not currently in Mathlib's `Nat.Digits` namespace.

### 2. Arithmetic Sum Formula (Mathlib)

**Theorems**:
- `sum_range_doubled`: `2 * Σ_{i=0}^{n-1} i = n * (n - 1)`
- `arith_sum_formula`: `Σ_{i=a}^{b} i = (b - a + 1) * (a + b) / 2`

**Note**: These may already exist in Mathlib in some form. Worth checking:
- `Finset.sum_range_id`
- `Nat.add_consecutive`

### 3. Closed-form Summation Pattern

**Technique**: Computing sum of all multiples of `m` in range `[lo, hi]` without iteration.

The pattern:
```lean
let minBase := (lo + m - 1) / m  -- ceiling
let maxBase := hi / m             -- floor
if minBase ≤ maxBase then
  let count := maxBase - minBase + 1
  let sumBases := count * (minBase + maxBase) / 2
  m * sumBases
else 0
```

This is a general technique but may not warrant a dedicated function.

## Assessment

- **repMultiplier**: Medium priority - useful for digit problems but niche
- **Arithmetic sum**: Check Mathlib first - likely exists
- **Closed-form pattern**: Document as technique rather than upstream
