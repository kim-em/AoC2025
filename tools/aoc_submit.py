#!/usr/bin/env python3
"""
AoC Submit Tool - Submit an answer and parse the response.

Usage: python tools/aoc_submit.py <day> <part> <answer> [--json]

Exit codes:
  0 - Correct answer
  1 - Wrong answer
  2 - Rate limited (check output for wait time)
  3 - Error (wrong level, not logged in, etc.)
"""

import argparse
import json
import re
import sys
from datetime import datetime

import requests
from bs4 import BeautifulSoup

from config import (
    PROGRESS_FILE,
    get_puzzle_status,
    get_session_cookie,
    save_puzzle_status,
    submit_url,
)


def parse_response(html: str) -> dict:
    """Parse AoC's response to an answer submission."""
    soup = BeautifulSoup(html, "html.parser")
    article = soup.find("article")

    if not article:
        return {
            "result": "error",
            "message": "Could not parse response",
        }

    text = article.get_text()

    # Check for correct answer
    if "That's the right answer" in text:
        return {
            "result": "correct",
            "message": "That's the right answer!",
        }

    # Check for wrong answer with hint
    if "That's not the right answer" in text:
        hint = None
        if "too high" in text.lower():
            hint = "too_high"
        elif "too low" in text.lower():
            hint = "too_low"

        return {
            "result": "wrong",
            "message": "That's not the right answer.",
            "hint": hint,
        }

    # Check for rate limiting
    if "You gave an answer too recently" in text:
        # Try to extract wait time
        match = re.search(r"You have (?:(\d+)m )?(\d+)s left to wait", text)
        wait_seconds = 0
        if match:
            minutes = int(match.group(1) or 0)
            seconds = int(match.group(2) or 0)
            wait_seconds = minutes * 60 + seconds

        return {
            "result": "rate_limited",
            "message": "You gave an answer too recently.",
            "wait_seconds": wait_seconds,
        }

    # Check for wrong level
    if "You don't seem to be solving the right level" in text:
        return {
            "result": "wrong_level",
            "message": "You don't seem to be solving the right level. Did you already complete it?",
        }

    # Check if already completed
    if "Did you already complete it" in text:
        return {
            "result": "already_complete",
            "message": "You've already completed this puzzle.",
        }

    # Unknown response
    return {
        "result": "unknown",
        "message": text[:200],
    }


def log_attempt(day: int, part: int, answer: str, result: dict) -> None:
    """Log the attempt to claude-progress.md."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
    result_str = result["result"]
    hint = result.get("hint", "")
    if hint:
        hint = f" ({hint.replace('_', ' ')})"

    entry = f"- [{timestamp}] Day {day} Part {part}: `{answer}` → {result_str}{hint}\n"

    # Append to progress file
    if PROGRESS_FILE.exists():
        content = PROGRESS_FILE.read_text()
    else:
        content = "# AoC 2025 Progress Log\n\n"

    # Check if we need a new date header
    today = datetime.now().strftime("%Y-%m-%d")
    if f"## {today}" not in content:
        content += f"\n## {today}\n\n"

    content += entry
    PROGRESS_FILE.write_text(content)


def submit_answer(day: int, part: int, answer: str, session: str) -> dict:
    """Submit an answer to AoC."""
    headers = {
        "Cookie": f"session={session}",
        "Content-Type": "application/x-www-form-urlencoded",
    }
    data = {
        "level": str(part),
        "answer": answer,
    }

    response = requests.post(submit_url(day), headers=headers, data=data)

    if response.status_code != 200:
        return {
            "result": "error",
            "message": f"HTTP {response.status_code}",
        }

    return parse_response(response.text)


def main():
    parser = argparse.ArgumentParser(description="Submit an answer to AoC")
    parser.add_argument("day", type=int, help="Day number (1-25)")
    parser.add_argument("part", type=int, choices=[1, 2], help="Part (1 or 2)")
    parser.add_argument("answer", type=str, help="Your answer")
    parser.add_argument("--json", action="store_true", help="Output JSON instead of human-readable")
    args = parser.parse_args()

    if not 1 <= args.day <= 25:
        print("Error: Day must be between 1 and 25", file=sys.stderr)
        return 3

    session = get_session_cookie()
    if not session:
        print("Error: No session cookie found. Run 'python tools/aoc_login.py' first.", file=sys.stderr)
        return 3

    # Submit the answer
    result = submit_answer(args.day, args.part, args.answer, session)
    result["day"] = args.day
    result["part"] = args.part
    result["answer"] = args.answer

    # Log the attempt
    log_attempt(args.day, args.part, args.answer, result)

    # Update status if correct
    if result["result"] == "correct":
        status = get_puzzle_status()
        day_str = str(args.day)
        part_key = f"part{args.part}"

        if day_str not in status["days"]:
            status["days"][day_str] = {}

        if part_key not in status["days"][day_str]:
            status["days"][day_str][part_key] = {"attempts": 0}

        status["days"][day_str][part_key]["status"] = "solved"
        status["days"][day_str][part_key]["answer"] = args.answer
        status["days"][day_str][part_key]["attempts"] = (
            status["days"][day_str][part_key].get("attempts", 0) + 1
        )

        # Unlock part 2 if part 1 was just solved
        if args.part == 1:
            status["days"][day_str]["part2"] = {"status": "pending", "attempts": 0}

        save_puzzle_status(status)
    elif result["result"] == "wrong":
        # Increment attempt count
        status = get_puzzle_status()
        day_str = str(args.day)
        part_key = f"part{args.part}"

        if day_str not in status["days"]:
            status["days"][day_str] = {}
        if part_key not in status["days"][day_str]:
            status["days"][day_str][part_key] = {"status": "pending", "attempts": 0}

        status["days"][day_str][part_key]["attempts"] = (
            status["days"][day_str][part_key].get("attempts", 0) + 1
        )
        save_puzzle_status(status)

    # Output result
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        if result["result"] == "correct":
            print(f"Correct! Day {args.day} Part {args.part} solved with answer: {args.answer}")
        elif result["result"] == "wrong":
            hint = result.get("hint", "")
            hint_msg = f" (your answer is {hint.replace('_', ' ')})" if hint else ""
            print(f"Wrong answer{hint_msg}. Try again.")
        elif result["result"] == "rate_limited":
            wait = result.get("wait_seconds", 0)
            print(f"Rate limited! Please wait {wait} seconds before trying again.")
        elif result["result"] == "wrong_level":
            print("Wrong level - you may have already completed this part.")
        elif result["result"] == "already_complete":
            print("You've already completed this puzzle.")
        else:
            print(f"Error: {result.get('message', 'Unknown error')}")

    # Set exit code based on result
    exit_codes = {
        "correct": 0,
        "wrong": 1,
        "rate_limited": 2,
        "wrong_level": 3,
        "already_complete": 0,  # Not really an error
        "error": 3,
        "unknown": 3,
    }
    return exit_codes.get(result["result"], 3)


if __name__ == "__main__":
    sys.exit(main())
