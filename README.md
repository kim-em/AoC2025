# Advent of Code 2025

Solutions to [Advent of Code 2025](https://adventofcode.com/2025) in Lean 4, with proofs of correctness where possible.

## Building

```bash
lake build
```

## Running

```bash
lake exe aoc2025 <day>
```

For example:
```bash
lake exe aoc2025 1
```

## Structure

- `AoC2025/` - Solution modules for each day
  - `DayXX.lean` - Main solution for day XX
  - `DayXX/Basic.lean` - Parsing and data structures
- `data/` - Input files (not committed, add your own)
  - `dayXX.txt` - Input for day XX
- `tools/` - Helper scripts for puzzle management
- `Main.lean` - CLI entry point

## Tools

Helper scripts for fetching puzzles, submitting answers, and scaffolding new days:

```bash
./tools/aoc_status.py          # Check solved/pending puzzles
./tools/aoc_fetch.py <day>     # Download puzzle description and input
./tools/setup_day.py <day>     # Scaffold Lean files for a new day
./tools/aoc_submit.py <day> <part> <answer>  # Submit an answer
./tools/aoc_login.py           # Configure AoC session cookie
```

## Adding a New Day

```bash
./tools/setup_day.py <day>
```

This creates the Lean files and updates imports automatically.

🤖 Solutions written by Claude
