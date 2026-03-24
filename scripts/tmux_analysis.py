#!/usr/bin/env python3
"""
Analyse tmux usage by combining:
  - atuin history (commands, timestamps, cwd, exit codes)
  - tmux event logs (session/window lifecycle)

Usage:
  python3 tmux_analysis.py              # analyse all time
  python3 tmux_analysis.py --days 7     # last 7 days
  python3 tmux_analysis.py --date 2026-03-15  # single day
"""

import argparse
import sqlite3
import os
import glob
import re
from datetime import datetime, timedelta, timezone
from collections import Counter, defaultdict


ATUIN_DB = os.path.expanduser("~/.local/share/atuin/history.db")
EVENTS_DIR = os.path.expanduser("~/tmux-logs")


# ---------------------------------------------------------------------------
# Data loading
# ---------------------------------------------------------------------------

def load_atuin(since: datetime | None, until: datetime | None) -> list[dict]:
    if not os.path.exists(ATUIN_DB):
        print(f"[warn] atuin db not found at {ATUIN_DB}")
        return []

    conn = sqlite3.connect(f"file:{ATUIN_DB}?mode=ro", uri=True)
    conn.row_factory = sqlite3.Row

    # atuin stores timestamps as nanoseconds since unix epoch
    conditions = []
    params = []
    if since:
        conditions.append("timestamp >= ?")
        params.append(int(since.timestamp() * 1_000_000_000))
    if until:
        conditions.append("timestamp < ?")
        params.append(int(until.timestamp() * 1_000_000_000))

    where = ("WHERE " + " AND ".join(conditions)) if conditions else ""
    rows = conn.execute(
        f"SELECT timestamp, command, cwd, exit, duration FROM history {where} ORDER BY timestamp",
        params,
    ).fetchall()
    conn.close()

    results = []
    for r in rows:
        ts = datetime.fromtimestamp(r["timestamp"] / 1_000_000_000, tz=timezone.utc).astimezone()
        results.append({
            "ts": ts,
            "command": r["command"].strip(),
            "cwd": r["cwd"] or "",
            "exit": r["exit"],
            "duration_ms": (r["duration"] or 0) // 1_000_000,
        })
    return results


def load_events(since: datetime | None, until: datetime | None) -> list[dict]:
    pattern = os.path.join(EVENTS_DIR, "events-*.log")
    files = sorted(glob.glob(pattern))
    events = []
    for path in files:
        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                parts = line.split(" ", 2)
                if len(parts) < 3:
                    continue
                try:
                    ts = datetime.fromisoformat(parts[0]).astimezone()
                except ValueError:
                    continue
                if since and ts < since:
                    continue
                if until and ts >= until:
                    continue
                events.append({"ts": ts, "event": parts[1], "target": parts[2]})
    return events


# ---------------------------------------------------------------------------
# Analysis
# ---------------------------------------------------------------------------

def top_commands(history: list[dict], n: int = 20) -> list[tuple[str, int]]:
    # Extract the base command (first word, strip leading sudo)
    def base(cmd: str) -> str:
        cmd = cmd.strip()
        if cmd.startswith("sudo "):
            cmd = cmd[5:]
        return cmd.split()[0] if cmd else ""

    counts = Counter(base(h["command"]) for h in history if base(h["command"]))
    return counts.most_common(n)


def top_directories(history: list[dict], n: int = 10) -> list[tuple[str, int]]:
    home = os.path.expanduser("~")
    def pretty(p: str) -> str:
        if p.startswith(home):
            return "~" + p[len(home):]
        return p
    counts = Counter(pretty(h["cwd"]) for h in history if h["cwd"])
    return counts.most_common(n)


def failure_rate(history: list[dict]) -> dict:
    total = len(history)
    failed = sum(1 for h in history if h["exit"] not in (0, None))
    return {"total": total, "failed": failed, "rate": failed / total if total else 0}


def commands_by_hour(history: list[dict]) -> dict[int, int]:
    counts: dict[int, int] = defaultdict(int)
    for h in history:
        counts[h["ts"].hour] += 1
    return dict(sorted(counts.items()))


def session_summary(events: list[dict]) -> list[dict]:
    sessions: dict[str, datetime] = {}
    durations = []
    for e in events:
        if e["event"] == "session-created":
            sessions[e["target"]] = e["ts"]
        elif e["event"] == "session-closed":
            name = e["target"]
            if name in sessions:
                dur = (e["ts"] - sessions.pop(name)).total_seconds() / 60
                durations.append({"name": name, "duration_min": round(dur, 1), "closed": e["ts"]})
    return durations


def top_sessions(events: list[dict], n: int = 10) -> list[tuple[str, int]]:
    counts = Counter(
        e["target"] for e in events if e["event"] == "session-created"
    )
    return counts.most_common(n)


def top_windows(events: list[dict], n: int = 10) -> list[tuple[str, int]]:
    counts = Counter(
        e["target"].split("/")[-1]
        for e in events
        if e["event"] == "window-created"
    )
    return counts.most_common(n)


# ---------------------------------------------------------------------------
# Rendering
# ---------------------------------------------------------------------------

def bar(value: int, max_value: int, width: int = 30) -> str:
    filled = int(width * value / max_value) if max_value else 0
    return "█" * filled + "░" * (width - filled)


def print_section(title: str):
    print(f"\n{'─' * 60}")
    print(f"  {title}")
    print(f"{'─' * 60}")


def render(history: list[dict], events: list[dict]):
    print_section("Top 20 commands")
    top = top_commands(history, 20)
    if top:
        max_count = top[0][1]
        for cmd, count in top:
            print(f"  {cmd:<25} {count:>6}  {bar(count, max_count, 20)}")
    else:
        print("  (no data)")

    print_section("Top directories")
    dirs = top_directories(history, 10)
    if dirs:
        max_count = dirs[0][1]
        for d, count in dirs:
            print(f"  {d:<45} {count:>5}  {bar(count, max_count, 15)}")
    else:
        print("  (no data)")

    print_section("Activity by hour")
    by_hour = commands_by_hour(history)
    if by_hour:
        max_count = max(by_hour.values())
        for hour in range(24):
            count = by_hour.get(hour, 0)
            print(f"  {hour:02d}:00  {bar(count, max_count, 40)}  {count}")
    else:
        print("  (no data)")

    print_section("Command failure rate")
    fr = failure_rate(history)
    print(f"  Total commands : {fr['total']}")
    print(f"  Failed         : {fr['failed']}  ({fr['rate']:.1%})")

    if events:
        print_section("tmux sessions created (most frequent)")
        for name, count in top_sessions(events, 10):
            print(f"  {name:<30} {count:>4}x")

        print_section("tmux windows created (most frequent)")
        for name, count in top_windows(events, 10):
            print(f"  {name:<30} {count:>4}x")

        durations = session_summary(events)
        if durations:
            print_section("Session durations (closed sessions)")
            for s in sorted(durations, key=lambda x: x["duration_min"], reverse=True)[:10]:
                print(f"  {s['name']:<30} {s['duration_min']:>7.1f} min")
    else:
        print("\n  [no tmux event logs found — run tmux and events will appear in ~/tmux-logs/]")

    print()


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Analyse tmux + shell usage")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--days", type=int, help="Analyse last N days")
    group.add_argument("--date", help="Analyse a single day (YYYY-MM-DD)")
    args = parser.parse_args()

    since = until = None

    if args.date:
        since = datetime.fromisoformat(args.date).replace(tzinfo=timezone.utc).astimezone()
        until = since + timedelta(days=1)
        label = f"Day: {args.date}"
    elif args.days:
        until = datetime.now().astimezone()
        since = until - timedelta(days=args.days)
        label = f"Last {args.days} days"
    else:
        label = "All time"

    print(f"\nTmux + Shell Usage Analysis — {label}")
    if since:
        print(f"  From : {since.strftime('%Y-%m-%d %H:%M')}")
    if until:
        print(f"  To   : {until.strftime('%Y-%m-%d %H:%M')}")

    history = load_atuin(since, until)
    events = load_events(since, until)

    print(f"\n  atuin records : {len(history)}")
    print(f"  tmux events   : {len(events)}")

    render(history, events)


if __name__ == "__main__":
    main()
