#!/usr/bin/env python3
"""Custom Claude Code status line.

Reads the session JSON that Claude Code pipes in on stdin and prints a
single status line showing: model, working dir + git branch, context
window usage, subscription quota (5-hour + 7-day rolling windows),
token count, and session cost.

Quota (`rate_limits`) is only present for Pro/Max subscribers and only
after the first API response of a session, so it degrades gracefully.
"""
import json
import os
import sys
import time
import subprocess

# --- ANSI helpers ----------------------------------------------------------
def c(code, text):
    return f"\033[{code}m{text}\033[0m"

DIM = "2"
CYAN = "36"
GREEN = "32"
YELLOW = "33"
RED = "31"
MAGENTA = "35"

SEP = c(DIM, " │ ")


def read_input():
    try:
        return json.load(sys.stdin)
    except Exception:
        return {}


def git_branch(cwd):
    try:
        out = subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True, text=True, timeout=0.5,
        )
        if out.returncode == 0:
            return out.stdout.strip()
    except Exception:
        pass
    return None


def pct_color(pct):
    if pct < 50:
        return GREEN
    if pct < 80:
        return YELLOW
    return RED


def fmt_tokens(n):
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.0f}k"
    return str(n)


def fmt_reset(resets_at):
    """Compact 'time until reset', e.g. 3h or 45m or 2d."""
    try:
        delta = int(resets_at) - int(time.time())
    except Exception:
        return None
    if delta <= 0:
        return None
    if delta >= 86400:
        return f"{delta // 86400}d"
    if delta >= 3600:
        return f"{delta // 3600}h"
    return f"{max(1, delta // 60)}m"


def main():
    data = read_input()
    parts = []

    # --- Model -------------------------------------------------------------
    model = data.get("model", {}) or {}
    model_name = model.get("display_name") or model.get("id") or "?"
    parts.append(c(MAGENTA, f"⚡ {model_name}"))

    # --- Directory + git branch -------------------------------------------
    workspace = data.get("workspace", {}) or {}
    cwd = workspace.get("current_dir") or data.get("cwd") or os.getcwd()
    dirname = os.path.basename(cwd.rstrip("/")) or "/"
    loc = c(CYAN, f"\U0001f4c1 {dirname}")
    branch = git_branch(cwd)
    if branch:
        loc += c(DIM, " on ") + c(GREEN, f" {branch}")
    parts.append(loc)

    # --- Context window usage (official pre-calculated fields) ------------
    ctx = data.get("context_window", {}) or {}
    used_pct = ctx.get("used_percentage")
    in_tok = ctx.get("total_input_tokens")
    out_tok = ctx.get("total_output_tokens")
    if used_pct is not None:
        total = (in_tok or 0) + (out_tok or 0)
        parts.append(
            c(pct_color(used_pct), f"\U0001f9e0 {used_pct:.0f}% ({fmt_tokens(total)})")
        )

    # --- Subscription quota: 5-hour + 7-day rolling windows ----------------
    rl = data.get("rate_limits", {}) or {}
    five = rl.get("five_hour", {}) or {}
    seven = rl.get("seven_day", {}) or {}

    if five.get("used_percentage") is not None:
        p = five["used_percentage"]
        seg = f"⏳ 5h {p:.0f}%"
        r = fmt_reset(five.get("resets_at"))
        if r:
            seg += c(DIM, f"·{r}")
        parts.append(c(pct_color(p), seg))

    if seven.get("used_percentage") is not None:
        p = seven["used_percentage"]
        seg = f"\U0001f4c5 7d {p:.0f}%"
        r = fmt_reset(seven.get("resets_at"))
        if r:
            seg += c(DIM, f"·{r}")
        parts.append(c(pct_color(p), seg))

    # --- Money (estimated, client-side) -----------------------------------
    cost = data.get("cost", {}) or {}
    total_cost = cost.get("total_cost_usd")
    if total_cost is not None:
        parts.append(c(YELLOW, f"\U0001f4b0 ${total_cost:.2f}"))

    # --- Lines changed -----------------------------------------------------
    added = cost.get("total_lines_added", 0)
    removed = cost.get("total_lines_removed", 0)
    if added or removed:
        parts.append(c(GREEN, f"+{added}") + c(DIM, "/") + c(RED, f"-{removed}"))

    sys.stdout.write(SEP.join(parts))


if __name__ == "__main__":
    main()
