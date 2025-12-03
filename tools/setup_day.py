#!/usr/bin/env python3
"""
Setup Day Tool - Scaffold Lean files for a new AoC day.

Usage: python tools/setup_day.py <day> [--json]

Creates:
- AoC2025/DayXX.lean (solution file)
- AoC2025/DayXX/Basic.lean (parsing/helpers)
- Updates AoC2025.lean with import
- Updates Main.lean with case
"""

import argparse
import json
import re
import sys
from pathlib import Path

from config import PROJECT_ROOT

LEAN_DIR = PROJECT_ROOT / "AoC2025"
ROOT_MODULE = PROJECT_ROOT / "AoC2025.lean"
MAIN_FILE = PROJECT_ROOT / "Main.lean"


def day_str(day: int) -> str:
    """Format day number with leading zero."""
    return f"{day:02d}"


def create_day_lean(day: int) -> Path:
    """Create the main DayXX.lean file."""
    path = LEAN_DIR / f"Day{day_str(day)}.lean"

    if path.exists():
        return None

    content = f'''/-
  # Advent of Code 2025 - Day {day_str(day)}
-/
import AoC2025.Day{day_str(day)}.Basic

namespace AoC2025.Day{day_str(day)}

-- Part 1
def part1 (input : String) : String :=
  sorry

-- Part 2
def part2 (input : String) : String :=
  sorry

end AoC2025.Day{day_str(day)}
'''
    path.write_text(content)
    return path


def create_basic_lean(day: int) -> Path:
    """Create the DayXX/Basic.lean file."""
    day_dir = LEAN_DIR / f"Day{day_str(day)}"
    day_dir.mkdir(exist_ok=True)

    path = day_dir / "Basic.lean"

    if path.exists():
        return None

    content = f'''/-
  # Day {day_str(day)} - Parsing and Data Structures
-/
import AoC2025.Basic

namespace AoC2025.Day{day_str(day)}

-- Add parsing functions and data structures here

end AoC2025.Day{day_str(day)}
'''
    path.write_text(content)
    return path


def update_root_module(day: int) -> bool:
    """Add import to AoC2025.lean if not present."""
    content = ROOT_MODULE.read_text()
    import_line = f"import AoC2025.Day{day_str(day)}"

    if import_line in content:
        return False

    # Add import at the end
    content = content.rstrip() + f"\n{import_line}\n"
    ROOT_MODULE.write_text(content)
    return True


def update_main(day: int) -> bool:
    """Add case to Main.lean if not present."""
    content = MAIN_FILE.read_text()

    # Check if case already exists
    case_pattern = rf"\| {day} =>"
    if re.search(case_pattern, content):
        return False

    # Find the "| _ =>" default case and insert before it
    ds = day_str(day)
    new_case = f'''  | {day} =>
    IO.println s!"Day {ds} Part 1: {{Day{ds}.part1 input}}"
    IO.println s!"Day {ds} Part 2: {{Day{ds}.part2 input}}"
'''

    # Insert before the default case
    default_pattern = r"(\s*\| _ =>)"
    if re.search(default_pattern, content):
        content = re.sub(default_pattern, new_case + r"\1", content)
    else:
        # No default case found, append before end of match
        content = content.replace("| _ =>", new_case + "  | _ =>")

    MAIN_FILE.write_text(content)
    return True


def main():
    parser = argparse.ArgumentParser(description="Scaffold Lean files for a new AoC day")
    parser.add_argument("day", type=int, help="Day number (1-25)")
    parser.add_argument("--json", action="store_true", help="Output JSON instead of human-readable")
    args = parser.parse_args()

    if not 1 <= args.day <= 25:
        print("Error: Day must be between 1 and 25", file=sys.stderr)
        return 1

    results = {
        "day": args.day,
        "created": [],
        "updated": [],
        "skipped": [],
    }

    # Create DayXX.lean
    day_lean = create_day_lean(args.day)
    if day_lean:
        results["created"].append(str(day_lean.relative_to(PROJECT_ROOT)))
    else:
        results["skipped"].append(f"AoC2025/Day{day_str(args.day)}.lean (already exists)")

    # Create DayXX/Basic.lean
    basic_lean = create_basic_lean(args.day)
    if basic_lean:
        results["created"].append(str(basic_lean.relative_to(PROJECT_ROOT)))
    else:
        results["skipped"].append(f"AoC2025/Day{day_str(args.day)}/Basic.lean (already exists)")

    # Update root module
    if update_root_module(args.day):
        results["updated"].append("AoC2025.lean")
    else:
        results["skipped"].append("AoC2025.lean (import already exists)")

    # Update Main.lean
    if update_main(args.day):
        results["updated"].append("Main.lean")
    else:
        results["skipped"].append("Main.lean (case already exists)")

    results["success"] = True

    if args.json:
        print(json.dumps(results, indent=2))
    else:
        print(f"Set up Day {day_str(args.day)}:")
        if results["created"]:
            print("  Created:")
            for f in results["created"]:
                print(f"    - {f}")
        if results["updated"]:
            print("  Updated:")
            for f in results["updated"]:
                print(f"    - {f}")
        if results["skipped"]:
            print("  Skipped:")
            for f in results["skipped"]:
                print(f"    - {f}")

        print(f"\nYou can now edit AoC2025/Day{day_str(args.day)}.lean to implement your solution.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
