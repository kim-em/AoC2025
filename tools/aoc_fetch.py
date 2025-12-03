#!/usr/bin/env python3
"""
AoC Fetch Tool - Download puzzle description and input.

Usage: python tools/aoc_fetch.py <day> [--json]

Downloads:
- Puzzle description to puzzles/dayXX.md
- Puzzle input to data/dayXX.txt
- Updates puzzle-status.json
"""
from __future__ import annotations

import argparse
import json
import re
import sys

import requests
from bs4 import BeautifulSoup

from config import (
    day_url,
    get_day_path,
    get_puzzle_status,
    get_session_cookie,
    input_url,
    save_puzzle_status,
)


def html_to_markdown(element) -> str:
    """Convert an HTML element to markdown."""
    result = []

    for child in element.children:
        if isinstance(child, str):
            result.append(child)
        elif child.name == "p":
            result.append(html_to_markdown(child) + "\n\n")
        elif child.name == "h2":
            text = child.get_text().strip()
            # Remove the "---" decorations AoC uses
            text = text.replace("---", "").strip()
            result.append(f"## {text}\n\n")
        elif child.name == "pre":
            code = child.get_text()
            result.append(f"```\n{code}```\n\n")
        elif child.name == "code":
            result.append(f"`{child.get_text()}`")
        elif child.name == "em":
            # AoC uses <em> for emphasis, often for the answer highlight
            text = child.get_text()
            if child.find_parent("code") or child.find_parent("pre"):
                result.append(text)
            else:
                result.append(f"**{text}**")
        elif child.name == "ul":
            for li in child.find_all("li", recursive=False):
                result.append(f"- {html_to_markdown(li).strip()}\n")
            result.append("\n")
        elif child.name == "li":
            result.append(html_to_markdown(child))
        elif child.name == "a":
            href = child.get("href", "")
            text = child.get_text()
            result.append(f"[{text}]({href})")
        elif child.name in ["span", "article"]:
            result.append(html_to_markdown(child))
        elif hasattr(child, "children"):
            result.append(html_to_markdown(child))

    return "".join(result)


def fetch_puzzle(day: int, session: str) -> tuple[str | None, bool, bool]:
    """
    Fetch puzzle description.

    Returns: (markdown_content, part1_available, part2_available)
    """
    headers = {"Cookie": f"session={session}"}
    response = requests.get(day_url(day), headers=headers)

    if response.status_code == 404:
        return None, False, False

    if response.status_code != 200:
        print(f"Error fetching puzzle: HTTP {response.status_code}", file=sys.stderr)
        return None, False, False

    soup = BeautifulSoup(response.text, "html.parser")

    # Find all article elements (one per part)
    articles = soup.find_all("article", class_="day-desc")

    if not articles:
        return None, False, False

    parts_md = []
    for article in articles:
        md = html_to_markdown(article)
        parts_md.append(md.strip())

    # Check if part 2 is available (will have 2 articles)
    part1_available = len(articles) >= 1
    part2_available = len(articles) >= 2

    # Combine all parts
    full_md = f"# Day {day}\n\n" + "\n\n---\n\n".join(parts_md)

    return full_md, part1_available, part2_available


def fetch_input(day: int, session: str) -> str | None:
    """Fetch puzzle input."""
    headers = {"Cookie": f"session={session}"}
    response = requests.get(input_url(day), headers=headers)

    if response.status_code == 404:
        return None

    if response.status_code != 200:
        print(f"Error fetching input: HTTP {response.status_code}", file=sys.stderr)
        return None

    # Check for error message
    if "Please don't repeatedly request this endpoint" in response.text:
        print("Error: Rate limited by AoC. Please wait before trying again.", file=sys.stderr)
        return None

    if "Puzzle inputs differ by user" in response.text:
        print("Error: Not logged in or invalid session.", file=sys.stderr)
        return None

    return response.text


def main():
    parser = argparse.ArgumentParser(description="Fetch AoC puzzle and input")
    parser.add_argument("day", type=int, help="Day number (1-25)")
    parser.add_argument("--json", action="store_true", help="Output JSON instead of human-readable")
    args = parser.parse_args()

    if not 1 <= args.day <= 25:
        print("Error: Day must be between 1 and 25", file=sys.stderr)
        return 1

    session = get_session_cookie()
    if not session:
        print("Error: No session cookie found. Run 'python tools/aoc_login.py' first.", file=sys.stderr)
        return 1

    puzzle_path, input_path = get_day_path(args.day)

    # Fetch puzzle description
    puzzle_md, part1_avail, part2_avail = fetch_puzzle(args.day, session)

    if puzzle_md is None:
        result = {
            "success": False,
            "error": f"Day {args.day} not available yet",
            "day": args.day,
        }
        if args.json:
            print(json.dumps(result, indent=2))
        else:
            print(f"Day {args.day} is not available yet.")
        return 1

    # Fetch input
    puzzle_input = fetch_input(args.day, session)

    if puzzle_input is None:
        result = {
            "success": False,
            "error": "Failed to fetch input",
            "day": args.day,
        }
        if args.json:
            print(json.dumps(result, indent=2))
        else:
            print("Failed to fetch puzzle input.")
        return 1

    # Save files
    puzzle_path.write_text(puzzle_md)
    input_path.write_text(puzzle_input)

    # Update status
    status = get_puzzle_status()
    day_str = str(args.day)
    if day_str not in status["days"]:
        status["days"][day_str] = {}

    day_status = status["days"][day_str]

    # Initialize part1 if not present
    if "part1" not in day_status:
        day_status["part1"] = {"status": "pending", "attempts": 0}

    # Initialize or update part2 based on availability
    if part2_avail:
        if "part2" not in day_status or day_status["part2"].get("status") == "locked":
            day_status["part2"] = {"status": "pending", "attempts": 0}
    else:
        if "part2" not in day_status:
            day_status["part2"] = {"status": "locked"}

    save_puzzle_status(status)

    result = {
        "success": True,
        "day": args.day,
        "puzzle_path": str(puzzle_path),
        "input_path": str(input_path),
        "part1_available": part1_avail,
        "part2_available": part2_avail,
        "input_lines": len(puzzle_input.strip().split("\n")),
    }

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(f"Fetched Day {args.day}:")
        print(f"  Puzzle: {puzzle_path}")
        print(f"  Input:  {input_path} ({result['input_lines']} lines)")
        print(f"  Part 1: {'available' if part1_avail else 'not available'}")
        print(f"  Part 2: {'available' if part2_avail else 'locked'}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
