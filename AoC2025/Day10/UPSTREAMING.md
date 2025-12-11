# Day 10 Upstream Candidates

## GF(2) Linear Algebra

The implementation includes a complete GF(2) (binary field) linear algebra solver:

### Components

1. **GF2Matrix representation**: `Array (Array Bool)` for matrices over GF(2)

2. **Gaussian elimination over GF(2)**:
   - `gaussianElimination`: Reduces to row echelon form, returns pivot columns
   - `swapRows`, `addRow`: Row operations

3. **Solution finding**:
   - `isConsistent`: Checks if system is solvable
   - `freeVariables`: Identifies free variables from pivot columns
   - `backSubstitute`: Finds particular solution given free variable values
   - `findMinSolution`: Brute-forces over free variables to find minimum Hamming weight solution

### Potential Value

GF(2) linear algebra has applications in:
- Coding theory (error-correcting codes)
- Cryptography
- Boolean satisfiability
- Combinatorial optimization

### Proved Properties

- `xorVec_self`: XOR is self-inverse
- `xorVec_comm`: XOR is commutative
- `countBits_all_false`: All-false vector has zero weight
- `swapRows_size`: Row swapping preserves matrix size

### Current Limitations

1. Uses `Array` with `!` indexing (may panic)
2. Missing: associativity, distributivity proofs
3. Missing: correctness theorem for Gaussian elimination
4. Uses `Id.run` imperative loops throughout

## natGcd

A simple recursive GCD implementation with proof that it equals `Nat.gcd`.

### Proved Properties

- `natGcd_eq_gcd`: Correctness (equals standard library GCD)
- `natGcd_dvd_left`, `natGcd_dvd_right`: Division properties

### Recommendation

Not needed for upstream - `Nat.gcd` already exists.

## Integer Linear Programming

The Part 2 solver implements integer Gaussian elimination and solution search:
- `intGaussianElimination`: Elimination over integers
- `solveMachineJoltage`: Finds minimum non-negative integer solution

This is more specialized and less suitable for upstream without significant generalization.
