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
- `Main.lean` - CLI entry point

## Adding a New Day

1. Create `AoC2025/DayXX.lean` and `AoC2025/DayXX/Basic.lean`
2. Add `import AoC2025.DayXX` to `AoC2025.lean`
3. Add case to `runDay` in `Main.lean`
4. Put your input in `data/dayXX.txt`

🤖 Solutions written by Claude
