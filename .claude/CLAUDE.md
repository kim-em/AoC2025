# AoC 2025 - Autonomous Agent Instructions

This file provides instructions for Claude to work autonomously on Advent of Code 2025 puzzles.

## Session Startup Ritual

When starting a new session to work on AoC:

0. **Log session start**: Add entry to `claude-progress.md`: `## YYYY-MM-DD HH:MM - Session started`
1. **Read progress log**: Review `claude-progress.md` to understand previous work
2. **Check status**: `./tools/aoc_status.py` to see solved/pending puzzles
3. **Check git status**: Verify no uncommitted work from previous sessions
4. **Identify next task**: The status tool shows the next unsolved puzzle

**Priority**: Solving puzzles always comes first. Only proceed to verification work (and Aristotle jobs) when all available puzzles are solved.

## Core Workflow

### Fetching a Puzzle

```bash
./tools/aoc_fetch.py <day>
```

This downloads:
- Puzzle description to `puzzles/dayXX.md`
- Input to `data/dayXX.txt`

### Setting Up a New Day

If the Lean files don't exist yet:

```bash
./tools/setup_day.py <day>
```

This creates:
- `AoC2025/DayXX.lean` - solution file
- `AoC2025/DayXX/Basic.lean` - parsing helpers
- Updates imports in `AoC2025.lean` and `Main.lean`

### Implementing a Solution

1. Read the puzzle: `cat puzzles/dayXX.md`
2. Examine the input: `head -20 data/dayXX.txt` to understand the format
3. Implement parsing in `AoC2025/DayXX/Basic.lean`
4. Implement solution in `AoC2025/DayXX.lean`
5. Test with: `lake exe aoc2025 <day>`

### Submitting an Answer

```bash
./tools/aoc_submit.py <day> <part> <answer>
```

Exit codes:
- 0: Correct answer
- 1: Wrong answer (check hint: too high/low)
- 2: Rate limited (wait and retry)
- 3: Error

### Handling Wrong Answers

When you get a wrong answer:
1. Note the hint (too high/too low) if provided
2. Re-examine your solution logic
3. Check edge cases in the input
4. If rate-limited, wait the specified time before retrying
5. Keep iterating until correct

**Do not give up on a puzzle.** AoC puzzles are always solvable with careful reading and logic.

## Commit Discipline

After solving each part:

1. Update `claude-progress.md` with what you did
2. Commit with message format: `Day XX Part Y: <brief description>`
3. Include the answer in the commit message if helpful

Example:
```bash
git add -A
git commit -m "Day 03 Part 1: Calculate sum of valid numbers (answer: 12345)"
```

## Post-Solve Workflow

After successfully submitting both parts for a day, continue with verification work:

### Phase A: Review & Refactor
- Review code for reusable components
- Factor out generally useful utilities to `AoC2025/Basic.lean`
- Generalize constructions where beneficial (without breaking the solution)
- Log: `Day XX: Refactored [description]`
- Commit: `Day XX: Refactor [description]`

### Phase B: Specification
- Write verification theorems specifying function behavior
- Focus on: algorithm correctness, termination, key invariants
- First pass: write theorem statements with `sorry` proofs
- Log: `Day XX: Added specifications [list theorem names]`
- Commit: `Day XX: Add specification theorems`

### Phase C: Proof
- Work through sorries, completing proofs
- Build up from simpler helper lemmas
- **Effort bound**: Try a few approaches per theorem. If stuck, move on and note it in the log.
- Log: `Day XX: Proved [theorem names]` or `Day XX: Stuck on [theorem] - [brief reason]`
- Commit after completing proofs: `Day XX: Prove [theorems]`

### Phase D: Proof Cleanup
- Review successful proofs for simplification
- Extract helper lemmas that are generally useful
- Combine redundant steps, test if `simp` can do more
- Log: `Day XX: Simplified proofs`
- Commit: `Day XX: Simplify proofs`

### Phase E: Upstream Identification
- Identify content potentially useful for Mathlib or lean4
- Create/update `AoC2025/DayXX/UPSTREAMING.md` with:
  - What could be upstreamed
  - Why it's useful beyond AoC
  - Current location in codebase
- Update root `UPSTREAMING.md` with one-line summary if any upstream candidates exist
- Log: `Day XX: Identified upstream candidates` (or skip if none)

**Constraint**: All verification work must relate to solving the day's problem. No novel material for its own sake.

## Using Aristotle for Proofs

Aristotle is an automated theorem prover that can fill in `sorry` placeholders. Use the `aristotle` skill for full documentation.

**Priority**: Aristotle is for verification work only. Solving puzzles always takes precedence. Only use Aristotle when all available puzzles are solved and you're working on Phase C (Proof).

### ARISTOTLE.md Tracking

Maintain an `ARISTOTLE.md` file at the project root with two sections:

```markdown
# Aristotle Jobs

## Pending

| Project ID | File | Submitted | Description |
|------------|------|-----------|-------------|
| abc123... | Day02/Basic.lean | 2025-12-07 14:30 | Specification theorems |

## Completed

| Project ID | File | Result | Notes |
|------------|------|--------|-------|
| def456... | Day01/Basic.lean | 3/5 proved | 2 false (see FIXMEs) |
```

### Starting Phase C (Proof Work)

Before writing new proofs, first check `ARISTOTLE.md` for completed jobs:
1. For any pending jobs, check their status via the Aristotle API
2. Download completed results and incorporate them:
   - Copy successful proofs into the original file
   - Add FIXME comments for false theorems (with counterexample explanation)
   - Add notes for theorems Aristotle couldn't prove
3. Move completed jobs from "Pending" to "Completed" with a summary
4. Delete the `*_aristotle.lean` output files after incorporation

### When to Send to Aristotle

Send proofs to Aristotle when:
- You've tried a few approaches and are stuck
- You have specification theorems with `sorry` that need filling
- You're ending a session with unfinished proofs

**Important**: Only one `sorry` per file. Before sending:
```lean
-- Change this:
theorem foo : ... := by sorry
theorem bar : ... := by sorry  -- also needs proving

-- To this:
theorem foo : ... := by sorry  -- Aristotle will work on this
theorem bar : ... := by admit  -- Aristotle will ignore this
```

### Async Workflow

Never wait for Aristotle to finish. After submitting:
1. Record the project ID in `ARISTOTLE.md` under "Pending"
2. Continue with other work, or end the session
3. Next session, check pending jobs and incorporate results

This allows proof work to proceed in parallel across sessions.

### Logging Format

Each phase should add an entry to `claude-progress.md`:
```
- [HH:MM] Day XX Phase Y: description
```

## Backlog Management

Days 1-4 were solved before the verification workflow was established and need upgrading.

**Priority**: New puzzles take precedence over backlog work.

**Backlog order**: Work on most promising candidates first. Based on current solutions:
1. **Day 2** (highest priority) - Sophisticated arithmetic algorithms, good verification targets
2. **Day 4** - Has `partial` function, termination proof candidate
3. **Day 3** - Greedy algorithm correctness
4. **Day 1** - Modular arithmetic properties

When no new puzzles are available, work through backlog starting from Phase A.

## Tool Creation

You are encouraged to create additional helper tools as needed:

- Add new Python scripts to `tools/`
- Document them in this file or in tool docstrings
- Common helpers might include:
  - Input visualization
  - Debug output formatting
  - Solution verification against examples

## Lean-Specific Guidelines

### Parsing Patterns

Common parsing patterns in `AoC2025/Basic.lean`:
- `lines` - split input into lines
- `parseNat?` - parse a natural number
- `parseInt?` - parse an integer

### Solution Structure

Each day follows this pattern:

```lean
def part1 (input : String) : String :=
  -- Parse input
  -- Compute answer
  -- Return as String (use toString for numbers)

def part2 (input : String) : String :=
  -- Similar structure
```

### Testing

Run your solution with:
```bash
lake exe aoc2025 <day>
```

The output shows both parts. Compare against examples in the puzzle description before submitting.

## Rate Limiting

AoC rate-limits submissions:
- After a wrong answer, you must wait before trying again
- The wait time increases with consecutive wrong answers
- The submit tool will tell you how long to wait

## File Locations

| File | Purpose |
|------|---------|
| `puzzles/dayXX.md` | Puzzle description |
| `data/dayXX.txt` | Puzzle input |
| `AoC2025/DayXX.lean` | Solution code |
| `AoC2025/DayXX/Basic.lean` | Parsing/helpers |
| `AoC2025/DayXX/UPSTREAMING.md` | Upstream candidates for this day |
| `puzzle-status.json` | Tracks solved status |
| `claude-progress.md` | Activity log |
| `ARISTOTLE.md` | Tracks pending/completed Aristotle jobs |
| `UPSTREAMING.md` | Summary of all upstream candidates |

## Example Session

```bash
# === Session Start ===
# Log start time to claude-progress.md
echo "## $(date '+%Y-%m-%d %H:%M') - Session started" >> claude-progress.md

# Check where we are
./tools/aoc_status.py
# Output: Next: Day 5 Part 1

# === Solve Phase ===
./tools/aoc_fetch.py 5
./tools/setup_day.py 5

# Read and understand the puzzle
cat puzzles/day05.md

# Implement solution in AoC2025/Day05.lean
# Test with: lake exe aoc2025 5

# Submit part 1
./tools/aoc_submit.py 5 1 "12345"
git add -A && git commit -m "Day 05 Part 1: [description]"

# Solve and submit part 2 similarly...

# === Post-Solve: Phase A - Refactor ===
# Review code, extract reusable utilities
# Log progress, then commit
git commit -m "Day 05: Refactor parsing utilities"

# === Post-Solve: Phase B - Specification ===
# Add theorem statements with sorry
git commit -m "Day 05: Add specification theorems"

# === Post-Solve: Phase C - Proof ===
# Complete proofs (or note stuck points in log)
git commit -m "Day 05: Prove correctness theorems"

# === Post-Solve: Phase D - Cleanup ===
# Simplify proofs, extract helper lemmas
git commit -m "Day 05: Simplify proofs"

# === Post-Solve: Phase E - Upstream ===
# If anything is generally useful, document in UPSTREAMING.md
```
