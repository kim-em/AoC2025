#!/usr/bin/env python3
"""
AoC Status Tool - Show puzzle completion status.

Usage: python tools/aoc_status.py [--json] [--sync]

Shows which days/parts are solved, pending, or locked.
Identifies the next puzzle to work on.
"""

import argparse
import json
import sys
from datetime import datetime

from config import (
    AOC_YEAR,
    get_day_path,
    get_puzzle_status,
    get_session_cookie,
    save_puzzle_status,
)


def get_available_day() -> int:
    """Get the latest available day based on current date."""
    now = datetime.now()
    if now.year < AOC_YEAR or (now.year == AOC_YEAR and now.month < 12):
        return 0
    if now.year > AOC_YEAR:
        return 25
    return min(now.day, 25)


def sync_with_website(session: str) -> dict:
    """Sync local status with AoC website."""
    import requests
    from bs4 import BeautifulSoup

    headers = {"Cookie": f"session={session}"}
    response = requests.get(f"https://adventofcode.com/{AOC_YEAR}", headers=headers)

    if response.status_code != 200:
        return None

    soup = BeautifulSoup(response.text, "html.parser")
    status = get_puzzle_status()

    # Find completed days from the calendar
    # Completed days have class "calendar-complete" or "calendar-verycomplete"
    for day_elem in soup.select(".calendar a"):
        classes = day_elem.get("class", [])
        day_match = day_elem.get("href", "").split("/")[-1]
        if not day_match.isdigit():
            continue
        day = int(day_match)
        day_str = str(day)

        if day_str not in status["days"]:
            status["days"][day_str] = {}

        if "calendar-verycomplete" in classes:
            # Both parts complete
            status["days"][day_str]["part1"] = status["days"][day_str].get("part1", {})
            status["days"][day_str]["part1"]["status"] = "solved"
            status["days"][day_str]["part2"] = status["days"][day_str].get("part2", {})
            status["days"][day_str]["part2"]["status"] = "solved"
        elif "calendar-complete" in classes:
            # Part 1 complete
            status["days"][day_str]["part1"] = status["days"][day_str].get("part1", {})
            status["days"][day_str]["part1"]["status"] = "solved"
            if "part2" not in status["days"][day_str]:
                status["days"][day_str]["part2"] = {"status": "pending", "attempts": 0}

    save_puzzle_status(status)
    return status


def find_next_puzzle(status: dict) -> tuple[int, int] | None:
    """Find the next unsolved puzzle."""
    available_day = get_available_day()

    for day in range(1, available_day + 1):
        day_str = str(day)
        day_data = status["days"].get(day_str, {})

        # Check part 1
        part1 = day_data.get("part1", {})
        if part1.get("status") != "solved":
            return (day, 1)

        # Check part 2
        part2 = day_data.get("part2", {})
        if part2.get("status") == "pending":
            return (day, 2)

    return None


def main():
    parser = argparse.ArgumentParser(description="Show AoC puzzle status")
    parser.add_argument("--json", action="store_true", help="Output JSON instead of human-readable")
    parser.add_argument("--sync", action="store_true", help="Sync with AoC website first")
    args = parser.parse_args()

    status = get_puzzle_status()

    # Sync if requested
    if args.sync:
        session = get_session_cookie()
        if not session:
            print("Warning: No session cookie, cannot sync", file=sys.stderr)
        else:
            synced = sync_with_website(session)
            if synced:
                status = synced
                if not args.json:
                    print("Synced with AoC website.\n")

    available_day = get_available_day()
    next_puzzle = find_next_puzzle(status)

    # Count stats
    total_stars = 0
    for day_data in status["days"].values():
        if day_data.get("part1", {}).get("status") == "solved":
            total_stars += 1
        if day_data.get("part2", {}).get("status") == "solved":
            total_stars += 1

    result = {
        "year": AOC_YEAR,
        "available_days": available_day,
        "total_stars": total_stars,
        "max_stars": available_day * 2,
        "next_puzzle": {"day": next_puzzle[0], "part": next_puzzle[1]} if next_puzzle else None,
        "days": {},
    }

    # Build per-day status
    for day in range(1, 26):
        day_str = str(day)
        day_data = status["days"].get(day_str, {})

        if day > available_day:
            result["days"][day_str] = {"part1": "unavailable", "part2": "unavailable"}
        else:
            part1_status = day_data.get("part1", {}).get("status", "pending")
            part2_status = day_data.get("part2", {}).get("status", "locked")
            result["days"][day_str] = {
                "part1": part1_status,
                "part2": part2_status,
                "part1_attempts": day_data.get("part1", {}).get("attempts", 0),
                "part2_attempts": day_data.get("part2", {}).get("attempts", 0),
            }

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(f"Advent of Code {AOC_YEAR} Status")
        print(f"Stars: {total_stars}/{available_day * 2}")
        print()

        # Show calendar grid
        print("Day  Part1  Part2  Attempts")
        print("-" * 30)
        for day in range(1, available_day + 1):
            day_str = str(day)
            day_info = result["days"][day_str]

            p1 = "★" if day_info["part1"] == "solved" else "○"
            p2 = "★" if day_info["part2"] == "solved" else ("○" if day_info["part2"] == "pending" else "·")

            attempts = day_info.get("part1_attempts", 0) + day_info.get("part2_attempts", 0)
            attempt_str = str(attempts) if attempts > 0 else ""

            # Check if puzzle files exist
            puzzle_path, input_path = get_day_path(day)
            has_files = "✓" if puzzle_path.exists() and input_path.exists() else ""

            print(f" {day:2d}    {p1}      {p2}     {attempt_str:3s}  {has_files}")

        print()
        if next_puzzle:
            print(f"Next: Day {next_puzzle[0]} Part {next_puzzle[1]}")
        else:
            print("All available puzzles completed!")

    return 0


if __name__ == "__main__":
    sys.exit(main())
