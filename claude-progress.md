# AoC 2025 Progress Log

This file tracks Claude's progress on Advent of Code 2025 puzzles.
Each session's work is logged here for continuity across sessions.


## 2025-12-03

- [2025-12-03 15:55] Day 1 Part 1: `1132` → correct
- [2025-12-03 15:56] Day 1 Part 2: `6623` → correct
- [2025-12-03 15:59] Day 2 Part 1: `54641809925` → correct
- [2025-12-03 16:01] Day 2 Part 2: `73694270688` → correct
- [2025-12-03 16:03] Day 3 Part 1: `17207` → correct
- [2025-12-03 16:04] Day 3 Part 2: `170997883706617` → correct

## 2025-12-04

- [2025-12-04 18:02] Day 4 Part 1: `1372` → correct
- [2025-12-04 18:03] Day 4 Part 2: `7922` → correct
## 2025-12-04 18:35 - Session started
- [18:36] Day 02 Phase A: Unified repMultiplier and sumRepetitionsInRange functions, removed duplicate code, fixed deprecation warning
- [18:38] Day 02 Phase B: Added 9 specification theorems (geomSum_eq, repMultiplier_eq_geomSum, repeated_digits_eq_mult, arith_sum_formula, isInvalid_iff_repeated_twice, isInvalidPart2_iff_repeated, sumRepetitionsInRange_correct, sumInvalidInRange_correct, sumInvalidInRangePart2_correct)
- [18:44] Day 02 Phase C: Added arithmetic sum theorem structure with sorry proofs - requires ring/linarith tactics (Mathlib dependency) for complete proofs
- [18:45] Day 02 Phase E: Identified repMultiplier as potential upstream candidate
- [18:47] Day 04 Phase A: Converted partial def to termination proof structure with countRolls, added removeRolls_decreases_count theorem
- [18:48] Day 04 Phase B: Added 7 specification theorems (isAccessible_spec, findAccessible_spec/valid, countAccessibleRolls_eq, removeRolls_effect/countRolls, removeAllAccessible_total)
- [18:49] Day 04 Phase E: Documented fixpoint termination pattern as potential upstream

## 2025-12-07 17:00 - Session started
- [17:00] Continued from previous session (context recovery)
- [17:15] Updated CLAUDE.md with Aristotle workflow documentation
- [17:20] Created ARISTOTLE.md for tracking prover jobs
- [17:25] Archived Claude conversation logs to claude-logs/
## 2025-12-07 17:27 - Session started
- [2025-12-07 17:34] Day 5 Part 1: `868` → correct
- [2025-12-07 17:35] Day 5 Part 2: `354143734113772` → correct
- [17:30] Day 05 Part 1: `868` → correct
- [17:31] Day 05 Part 2: `354143734113772` → correct
- [2025-12-07 17:38] Day 6 Part 1: `5227286044585` → correct
- [2025-12-07 17:40] Day 6 Part 2: `10227753257799` → correct
- [17:35] Day 06 Part 1: `5227286044585` → correct
- [17:36] Day 06 Part 2: `10227753257799` → correct
- [2025-12-07 17:43] Day 7 Part 1: `1640` → correct
- [2025-12-07 17:45] Day 7 Part 2: `40999072541589` → correct
## 2025-12-07 17:54 - Session started
- [18:02] Day 05 Phase A+B: Added specification theorems (Range.contains_iff, inAnyRange_iff, Range.size_eq, Range.contains_max proved; mergeRanges theorems marked admit due to qsort complexity)
- [18:02] Day 06 Phase A+B: Added specification theorems for Problem.eval (all proved by rfl/simp)
- [18:02] Day 07 Phase A+B: Added specification theorems (dedup_nodup, mem_dedup_iff, mergeTimelines_sum with sorry; split_doubles_timelines, timelines_eq_two_pow_splits proved)
- [18:02] Day 01 Phase B: Added specification theorems (applyRotation_lt_100, applyRotation_zero_dist, applyRotation_left_100, applyRotation_right_100, countZeroCrossings variants - all proved)
- [18:02] Day 03 Phase B: Added specification theorems (charToDigit examples proved, maxJoltage_empty/singleton proved, maxJoltage_le_99 and maxJoltageK_greedy with sorry)
