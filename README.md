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

Or use the setup tool: `python tools/setup_day.py <day>`

## Autonomous Agent Setup

This repository includes tools for Claude to solve puzzles autonomously.

### Installation

```bash
pip install -r requirements.txt
playwright install chromium
```

### Login to AoC

```bash
python tools/aoc_login.py
```

This opens a browser window. Log in with GitHub/Google/etc, and the session cookie is saved automatically.

### Start Solving

```bash
claude -p "Work on AoC - check status and solve the next puzzle"
```

Claude will:
1. Check `puzzle-status.json` to find the next unsolved puzzle
2. Fetch the puzzle description and input
3. Scaffold Lean files if needed
4. Implement the solution
5. Submit the answer (retrying on wrong answers)
6. Commit after each solved part

### Tools

| Tool | Purpose |
|------|---------|
| `python tools/aoc_login.py` | Browser login to extract session cookie |
| `python tools/aoc_fetch.py <day>` | Download puzzle and input |
| `python tools/aoc_submit.py <day> <part> <answer>` | Submit an answer |
| `python tools/aoc_status.py` | Show completion status |
| `python tools/setup_day.py <day>` | Scaffold Lean files for a day |

All tools support `--json` for structured output.

🤖 Solutions written by Claude
