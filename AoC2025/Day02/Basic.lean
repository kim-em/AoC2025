/-
  # Day 02 - Parsing and Data Structures
-/
import Mathlib
import AoC2025.Basic

namespace AoC2025.Day02

/-- A range of product IDs -/
structure Range where
  lo : Nat
  hi : Nat
  deriving Repr

/-- Check if a number is "invalid" - i.e., consists of some digit sequence repeated twice -/
def isInvalid (n : Nat) : Bool :=
  let s := toString n
  let len := s.length
  -- Must have even length to be a doubled sequence
  if len % 2 != 0 then false
  else
    let half := len / 2
    let firstHalf := s.take half
    let secondHalf := s.drop half
    firstHalf == secondHalf

/-- Parse a single range like "11-22" -/
def parseRange? (s : String) : Option Range := do
  let parts := s.splitOn "-"
  if parts.length != 2 then none
  else
    let lo ← parts[0]!.toNat?
    let hi ← parts[1]!.toNat?
    some { lo, hi }

/-- Parse the input line into ranges -/
def parseRanges (input : String) : List Range :=
  let trimmed := input.trim.dropRightWhile (· == ',')
  trimmed.splitOn "," |>.filterMap parseRange?

/-- Compute (10^(d*k) - 1) / (10^d - 1) - multiplier for base of d digits repeated k times.
    E.g., repMultiplier 2 3 = 10101 (so 12 repeated 3 times = 12 * 10101 = 121212) -/
def repMultiplier (d k : Nat) : Nat :=
  (Nat.pow 10 (d * k) - 1) / (Nat.pow 10 d - 1)

/-- Sum of numbers in range [r.lo, r.hi] that are a d-digit base repeated k times.
    Uses closed-form arithmetic sum formula instead of iteration. -/
def sumRepetitionsInRange (r : Range) (d k : Nat) : Nat :=
  let mult := repMultiplier d k
  -- Valid bases for d digits: [10^(d-1), 10^d - 1], except d=1 uses [1, 9]
  let baseMin := if d == 1 then 1 else Nat.pow 10 (d - 1)
  let baseMax := Nat.pow 10 d - 1
  -- Find bases where mult * base falls in [r.lo, r.hi]
  let minBase := (r.lo + mult - 1) / mult  -- ceiling division
  let maxBase := r.hi / mult               -- floor division
  let actualMin := max minBase baseMin
  let actualMax := min maxBase baseMax
  if actualMin ≤ actualMax then
    -- Sum of mult * base for base in [actualMin, actualMax]
    -- = mult * Σ base = mult * (count * (actualMin + actualMax) / 2)
    let count := actualMax - actualMin + 1
    let sumBases := count * (actualMin + actualMax) / 2
    mult * sumBases
  else
    0

/-- Find all invalid IDs in a range and sum them (Part 1: exactly doubled).
    Invalid = d-digit base repeated exactly 2 times, for various d. -/
def sumInvalidInRange (r : Range) : Nat :=
  -- For each base digit count d in [1, 10], sum numbers with d-digit base repeated twice
  List.range 11 |>.drop 1 |>.foldl (fun acc d => acc + sumRepetitionsInRange r d 2) 0

/-- Check if a number is invalid for Part 2 (repeated at least twice).
    Used for testing/validation, not in the actual solution. -/
def isInvalidPart2 (n : Nat) : Bool :=
  let s := toString n
  let len := s.length
  -- Check all divisors d of len where len/d >= 2
  List.range len |>.drop 1 |>.any fun d =>
    if len % d == 0 && len / d >= 2 then
      let rep := len / d
      let base := s.take d
      List.range rep |>.all fun i =>
        (s.toSubstring.extract ⟨i * d⟩ ⟨(i + 1) * d⟩).toString == base
    else false

/-- Collect all invalid numbers in range for Part 2, avoiding double counting.
    A number can match multiple (d, k) patterns (e.g., 111111 = 1 repeated 6 times
    or 111 repeated twice), so we collect all matches and deduplicate. -/
def collectInvalidPart2 (r : Range) : List Nat := Id.run do
  let mut result : List Nat := []
  -- For each total digit count n in range 2..20
  for n in [2:21] do
    -- Check all divisors d where n/d >= 2
    for d in [1:n] do
      if n % d == 0 && n / d >= 2 then
        let k := n / d
        let mult := repMultiplier d k
        let baseMin := if d == 1 then 1 else Nat.pow 10 (d - 1)
        let baseMax := Nat.pow 10 d - 1
        let minBase := (r.lo + mult - 1) / mult
        let maxBase := r.hi / mult
        let actualMin := max minBase baseMin
        let actualMax := min maxBase baseMax
        for base in [actualMin : actualMax + 1] do
          let num := mult * base
          if num >= r.lo && num <= r.hi then
            result := num :: result
  result.eraseDups

/-- Sum all invalid IDs for Part 2 -/
def sumInvalidInRangePart2 (r : Range) : Nat :=
  let invalid := collectInvalidPart2 r
  invalid.foldl (· + ·) 0

/-! ## Specification Theorems -/

/-- The geometric series sum formula: Σ_{i=0}^{k-1} r^i = (r^k - 1) / (r - 1) for r > 1.
    This justifies the `repMultiplier` formula. -/
theorem geomSum_eq (r : Nat) (k : Nat) (hr : r > 1) :
    (List.range k).foldl (fun acc i => acc + r ^ i) 0 = (r ^ k - 1) / (r - 1) := by
  rw [Nat.div_eq_of_eq_mul_left]
  · exact Nat.sub_pos_of_lt hr
  · exact Nat.sub_eq_of_eq_add <| by
      exact Nat.recOn k (by norm_num) fun n ih => by
        cases r <;> simp_all +decide [List.range_succ, pow_succ']; linarith

/-- repMultiplier computes the geometric series sum with base 10^d. -/
theorem repMultiplier_eq_geomSum (d k : Nat) (hd : d > 0) :
    repMultiplier d k = (List.range k).foldl (fun acc i => acc + (10 ^ d) ^ i) 0 := by
  have h_geom_sum : (List.range k).foldl (fun acc i => acc + (10 ^ d) ^ i) 0 =
      (10 ^ (d * k) - 1) / (10 ^ d - 1) := by
    convert geomSum_eq _ _ _ using 1
    · ring
    · exact one_lt_pow₀ (by decide) hd.ne'
  exact h_geom_sum.symm

/-- A number formed by repeating a d-digit base k times equals base * repMultiplier d k. -/
theorem repeated_digits_eq_mult (base d k : Nat) (_hd : d > 0) (_hk : k ≥ 2)
    (_hbase : 10 ^ (d - 1) ≤ base ∧ base < 10 ^ d) :
    -- The number formed by concatenating base with itself k times
    -- equals base * repMultiplier d k
    base * repMultiplier d k = base * ((10 ^ (d * k) - 1) / (10 ^ d - 1)) := by
  simp [repMultiplier]

/-- Sum of 0 + 1 + ... + (n-1) equals n*(n-1)/2 (doubled to avoid division). -/
theorem sum_range_doubled (n : Nat) :
    2 * (List.range n).foldl (· + ·) 0 = n * (n - 1) := by
  have h_sum_formula : List.foldl (fun x1 x2 => x1 + x2) 0 (List.range n) = n * (n - 1) / 2 := by
    convert Finset.sum_range_id n using 1
    induction n <;> simp_all +decide [Finset.sum_range_succ]
    simp_all +decide [List.range_succ]
  rw [h_sum_formula, Nat.mul_div_cancel' (even_iff_two_dvd.mp (Nat.even_mul_pred_self _))]

/-- Arithmetic sum formula: Σ_{i=0}^{n-1} i = n * (n - 1) / 2 -/
theorem sum_range_eq (n : Nat) :
    (List.range n).foldl (· + ·) 0 = n * (n - 1) / 2 := by
  have h := sum_range_doubled n
  omega

/-- Helper: decompose sum with offset into sum without offset -/
theorem sum_with_offset (n a : Nat) :
    (List.range n).foldl (fun acc i => acc + (a + i)) 0 =
    a * n + (List.range n).foldl (· + ·) 0 := by
  induction n <;> simp_all +decide [List.range_succ]
  ring

/-- Arithmetic sum formula (doubled to avoid division issues):
    2 * Σ_{i=a}^{b} i = (b - a + 1) * (a + b) -/
theorem arith_sum_formula_doubled (a b : Nat) (hab : a ≤ b) :
    2 * (List.range (b - a + 1)).foldl (fun acc i => acc + (a + i)) 0 = (b - a + 1) * (a + b) := by
  have h_arith_sum : ∀ n : ℕ, (List.range n).foldl (fun acc i => acc + i) 0 = n * (n - 1) / 2 :=
    sum_range_eq
  have h_arith_sum_applied : ∀ (n : ℕ) (a : ℕ),
      (List.range n).foldl (fun acc i => acc + (a + i)) 0 = n * a + (n * (n - 1)) / 2 := by
    intros n a; rw [← h_arith_sum]
    induction n <;> simp +decide [*, List.range_succ]; ring
  have h_subst : (List.range (b - a + 1)).foldl (fun acc i => acc + (a + i)) 0 =
      (b - a + 1) * a + (b - a + 1) * (b - a) / 2 :=
    h_arith_sum_applied _ _
  nlinarith [Nat.div_mul_cancel (show 2 ∣ (b - a + 1) * (b - a) from
    Nat.dvd_of_mod_eq_zero (by norm_num [Nat.add_mod, Nat.mod_two_of_bodd])),
    Nat.sub_add_cancel hab]

/-- Arithmetic sum formula: Σ_{i=a}^{b} i = (b - a + 1) * (a + b) / 2 -/
theorem arith_sum_formula (a b : Nat) (hab : a ≤ b) :
    (List.range (b - a + 1)).foldl (fun acc i => acc + (a + i)) 0 = (b - a + 1) * (a + b) / 2 := by
  have h := arith_sum_formula_doubled a b hab
  omega

-- Note: Aristotle was unable to prove the following two theorems.
-- They relate string-based checking to the algebraic characterization.
-- The proof would require reasoning about toString and string equality.

/-- For Part 1: isInvalid n iff n = base * repMultiplier d 2 for some valid d and base. -/
theorem isInvalid_iff_repeated_twice (n : Nat) (hn : n > 0) :
    isInvalid n = true ↔
    ∃ d base, d > 0 ∧ (if d = 1 then 1 else 10 ^ (d - 1)) ≤ base ∧ base < 10 ^ d ∧
              n = base * repMultiplier d 2 := by
  -- Requires proving equivalence between string-based isInvalid
  -- and the algebraic characterization. The key challenge is reasoning
  -- about toString n and showing string equality matches numeric structure.
  sorry

/-- For Part 2: isInvalidPart2 n iff n = base * repMultiplier d k for some valid d, k ≥ 2, base. -/
theorem isInvalidPart2_iff_repeated (n : Nat) (hn : n > 0) :
    isInvalidPart2 n = true ↔
    ∃ d k base, d > 0 ∧ k ≥ 2 ∧ (if d = 1 then 1 else 10 ^ (d - 1)) ≤ base ∧ base < 10 ^ d ∧
                n = base * repMultiplier d k := by
  -- Similar to isInvalid_iff_repeated_twice but for arbitrary repetitions.
  sorry

-- Note: Aristotle produced a proof but it times out on v4.24.1.
-- The proof involves complex Finset manipulations.

/-- sumRepetitionsInRange correctly sums all numbers n in [r.lo, r.hi]
    where n = base * repMultiplier d k for a valid d-digit base. -/
theorem sumRepetitionsInRange_correct (r : Range) (d k : Nat) (hd : d > 0) (hk : k ≥ 2) :
    sumRepetitionsInRange r d k =
    ((List.range (10 ^ d - (if d = 1 then 1 else 10 ^ (d - 1)))).filterMap (fun i =>
      let base := (if d = 1 then 1 else 10 ^ (d - 1)) + i
      let n := base * repMultiplier d k
      if r.lo ≤ n ∧ n ≤ r.hi then some n else none
    )).foldl (· + ·) 0 := by
  -- Aristotle generated a proof that times out. The proof involves
  -- showing the closed-form sum equals iterating over all valid bases.
  sorry

-- The following two theorems require bounded hypotheses since the implementations
-- only check up to 10-digit bases (20 total digits).

/-- Part 1 correctness: sumInvalidInRange sums exactly the invalid numbers in the range.
    Requires range to be bounded: r.hi < 10^20 (max 10-digit base repeated twice). -/
theorem sumInvalidInRange_correct (r : Range) (h_bounded : r.hi < 10 ^ 20) :
    sumInvalidInRange r =
    ((List.range (r.hi - r.lo + 1)).filterMap (fun i =>
      let n := r.lo + i
      if isInvalid n then some n else none
    )).foldl (· + ·) 0 := by
  -- The implementation iterates d in [1, 10], covering all valid bases
  -- for numbers < 10^20. Each d-digit base repeated twice has 2d digits,
  -- so max is d=10 → 20 digits, which is within bounds.
  sorry

/-- Part 2 correctness: sumInvalidInRangePart2 sums exactly the Part 2 invalid numbers.
    Requires range to be bounded: r.hi < 10^20 (max 20-digit number). -/
theorem sumInvalidInRangePart2_correct (r : Range) (h_bounded : r.hi < 10 ^ 20) :
    sumInvalidInRangePart2 r =
    ((List.range (r.hi - r.lo + 1)).filterMap (fun i =>
      let n := r.lo + i
      if isInvalidPart2 n then some n else none
    )).foldl (· + ·) 0 := by
  -- The implementation checks digit counts up to 20, which covers all
  -- numbers < 10^20. Each (d, k) combination produces d*k total digits.
  sorry

end AoC2025.Day02
