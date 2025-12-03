#!/usr/bin/env python3
"""
AoC Login Tool - Use Playwright to log in and extract session cookie.

Usage: python tools/aoc_login.py

This will:
1. Launch a browser window
2. Navigate to adventofcode.com
3. Wait for you to log in manually (GitHub, Google, etc.)
4. Extract the session cookie once logged in
5. Save it to .aoc-session
6. Verify the cookie works
"""
from __future__ import annotations

import argparse
import sys

from playwright.sync_api import sync_playwright

from config import (
    AOC_BASE_URL,
    AOC_YEAR,
    get_session_cookie,
    save_session_cookie,
)


def login_and_extract_cookie() -> str | None:
    """Launch browser for login and extract session cookie."""
    print("Launching browser for AoC login...")
    print("Please log in using your preferred method (GitHub, Google, etc.)")
    print("The browser will close automatically once logged in.\n")

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        page = context.new_page()

        # Navigate to AoC
        page.goto(AOC_BASE_URL)

        # Wait for user to log in - check for the presence of a logged-in indicator
        # The settings link only appears when logged in
        print("Waiting for login... (look for [Settings] link in top right)")

        try:
            # Poll for the settings link which indicates successful login
            page.wait_for_selector('a[href="/2025/settings"]', timeout=300000)  # 5 min timeout
            print("\nLogin detected!")
        except Exception:
            print("\nTimeout waiting for login. Please try again.")
            browser.close()
            return None

        # Extract session cookie
        cookies = context.cookies()
        session_cookie = None
        for cookie in cookies:
            if cookie["name"] == "session" and "adventofcode.com" in cookie["domain"]:
                session_cookie = cookie["value"]
                break

        browser.close()

        return session_cookie


def verify_cookie(cookie: str) -> bool:
    """Verify the cookie works by fetching a protected page."""
    import requests

    print("Verifying cookie...")
    headers = {"Cookie": f"session={cookie}"}
    # Try to fetch day 1 input (should exist for any logged-in user during December)
    response = requests.get(f"{AOC_BASE_URL}/{AOC_YEAR}/day/1/input", headers=headers)

    if response.status_code == 200 and "Puzzle inputs differ by user" not in response.text:
        print("Cookie verified successfully!")
        return True
    else:
        print(f"Cookie verification failed (status: {response.status_code})")
        return False


def main():
    parser = argparse.ArgumentParser(description="Log in to Advent of Code and save session cookie")
    parser.add_argument("--force", "-f", action="store_true", help="Replace existing cookie")
    args = parser.parse_args()

    # Check if cookie already exists
    existing = get_session_cookie()
    if existing and not args.force:
        print("Session cookie already exists.")
        if verify_cookie(existing):
            print("Existing cookie is still valid. Use --force to replace.")
            return 0
        else:
            print("Existing cookie is invalid, proceeding with new login...")

    # Perform login
    cookie = login_and_extract_cookie()

    if not cookie:
        print("Failed to extract session cookie.")
        return 1

    # Verify it works
    if not verify_cookie(cookie):
        print("Warning: Cookie extracted but verification failed.")
        print("Saving anyway - you may need to try again.")

    # Save cookie
    save_session_cookie(cookie)
    print(f"\nSession cookie saved to .aoc-session")
    print("You can now use the other AoC tools.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
