# AoC 2025 - Autonomous Agent Instructions

This file provides instructions for Claude to work autonomously on Advent of Code 2025 puzzles.

## Session Startup Ritual

When starting a new session to work on AoC:

1. **Read progress log**: `cat claude-progress.md` to understand previous work
2. **Check status**: `./tools/aoc_status.py` to see solved/pending puzzles
3. **Check git status**: Verify no uncommitted work from previous sessions
4. **Identify next task**: The status tool shows the next unsolved puzzle

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
| `puzzle-status.json` | Tracks solved status |
| `claude-progress.md` | Activity log |

## Example Session

```bash
# Check where we are
./tools/aoc_status.py
# Output: Next: Day 3 Part 1

# Fetch the puzzle
./tools/aoc_fetch.py 3

# Set up Lean files if needed
./tools/setup_day.py 3

# Read and understand the puzzle
cat puzzles/day03.md

# Implement solution...
# (edit AoC2025/Day03.lean)

# Test
lake exe aoc2025 3

# Submit
./tools/aoc_submit.py 3 1 "12345"

# If correct, commit
git add -A
git commit -m "Day 03 Part 1: Find sum of gear ratios"

# Continue to part 2...
```
