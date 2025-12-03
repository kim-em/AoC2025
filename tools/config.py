"""
Shared configuration for AoC tools.
"""

from __future__ import annotations

import json
from datetime import datetime
from pathlib import Path

# Paths
PROJECT_ROOT = Path(__file__).parent.parent
TOOLS_DIR = PROJECT_ROOT / "tools"
DATA_DIR = PROJECT_ROOT / "data"
PUZZLES_DIR = PROJECT_ROOT / "puzzles"
SESSION_FILE = PROJECT_ROOT / ".aoc-session"
STATUS_FILE = PROJECT_ROOT / "puzzle-status.json"
PROGRESS_FILE = PROJECT_ROOT / "claude-progress.md"

# AoC configuration
AOC_YEAR = 2025
AOC_BASE_URL = "https://adventofcode.com"

# Ensure directories exist
DATA_DIR.mkdir(exist_ok=True)
PUZZLES_DIR.mkdir(exist_ok=True)


def get_session_cookie() -> str | None:
    """Load session cookie from file."""
    if SESSION_FILE.exists():
        return SESSION_FILE.read_text().strip()
    return None


def save_session_cookie(cookie: str) -> None:
    """Save session cookie to file."""
    SESSION_FILE.write_text(cookie + "\n")
    # Make file readable only by owner
    SESSION_FILE.chmod(0o600)


def get_puzzle_status() -> dict:
    """Load puzzle status from JSON file."""
    if STATUS_FILE.exists():
        return json.loads(STATUS_FILE.read_text())
    return {
        "year": AOC_YEAR,
        "days": {},
        "last_updated": None
    }


def save_puzzle_status(status: dict) -> None:
    """Save puzzle status to JSON file."""
    status["last_updated"] = datetime.utcnow().isoformat() + "Z"
    STATUS_FILE.write_text(json.dumps(status, indent=2) + "\n")


def get_day_path(day: int) -> tuple[Path, Path]:
    """Get paths for a day's puzzle and input files."""
    day_str = f"{day:02d}"
    puzzle_path = PUZZLES_DIR / f"day{day_str}.md"
    input_path = DATA_DIR / f"day{day_str}.txt"
    return puzzle_path, input_path


def day_url(day: int) -> str:
    """Get URL for a day's puzzle page."""
    return f"{AOC_BASE_URL}/{AOC_YEAR}/day/{day}"


def input_url(day: int) -> str:
    """Get URL for a day's input."""
    return f"{AOC_BASE_URL}/{AOC_YEAR}/day/{day}/input"


def submit_url(day: int) -> str:
    """Get URL for submitting an answer."""
    return f"{AOC_BASE_URL}/{AOC_YEAR}/day/{day}/answer"
