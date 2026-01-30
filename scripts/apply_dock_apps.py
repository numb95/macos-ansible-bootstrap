#!/usr/bin/env python3
import argparse
import json
import os
import plistlib
import urllib.parse
from pathlib import Path

def normalize_url(item: str) -> str:
    if item.startswith("file://"):
        return item
    # Treat as path
    return "file://" + urllib.parse.quote(item)

def build_entry(url: str) -> dict:
    return {
        "tile-data": {
            "file-data": {
                "_CFURLString": url,
                "_CFURLStringType": 15,
            }
        },
        "tile-type": "file-tile",
    }

def main() -> int:
    parser = argparse.ArgumentParser(description="Apply Dock persistent apps list")
    parser.add_argument("apps_json", help="Path to JSON list of app URLs/paths")
    args = parser.parse_args()

    apps_path = Path(args.apps_json)
    apps = json.loads(apps_path.read_text())
    if not isinstance(apps, list):
        raise SystemExit("apps_json must be a JSON array")

    plist_path = Path.home() / "Library/Preferences/com.apple.dock.plist"
    if plist_path.exists():
        with plist_path.open("rb") as f:
            data = plistlib.load(f)
    else:
        data = {}

    entries = [build_entry(normalize_url(a)) for a in apps]
    data["persistent-apps"] = entries

    # Write back as XML plist (Dock accepts it)
    with plist_path.open("wb") as f:
        plistlib.dump(data, f)

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
