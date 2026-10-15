#!/usr/bin/env python3
"""Claude Code hook: a desktop notification (shown by dunst) when Claude
finishes a response or is blocked waiting on you -- but only when the window
this session runs in (its terminal, or Claude Desktop) is not focused.

    desktop-notify.py stop       Stop hook: "finished" with the start of
                                 Claude's last reply (normal urgency)
    desktop-notify.py attention  Notification hook: permission prompts and
                                 questions (critical, stays until dismissed)
"""
import html
import json
import os
import re
import subprocess
import sys
import time

PREVIEW_LENGTH = 140


def output(*cmd):
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout.strip() if result.returncode == 0 else ""


def parent(pid):
    with open(f"/proc/{pid}/stat") as stat:
        return int(stat.read().rsplit(")", 1)[1].split()[1])


def session_focused():
    """Whether the window this session runs in is the focused one: the
    focused window's process (from Hyprland) must be one of this hook's
    ancestors, i.e. the terminal or Claude Desktop this session runs in."""
    try:
        active = json.loads(output("hyprctl", "activewindow", "-j") or "{}").get("pid")
    except ValueError:
        return False
    pid = os.getppid()
    while pid > 1:
        if pid == active:
            return True
        pid = parent(pid)
    return False


def final_text(path):
    """Text Claude wrote after its last tool use or your last message: the
    final reply of the turn. None if it isn't in the transcript yet."""
    try:
        with open(os.path.expanduser(path)) as transcript:
            lines = transcript.readlines()
    except OSError:
        return None
    texts = []
    for line in reversed(lines):  # newest first
        try:
            entry = json.loads(line)
        except ValueError:
            continue
        if entry.get("isSidechain") or entry.get("type") not in ("assistant", "user"):
            continue  # subagents' messages and bookkeeping entries
        if entry["type"] == "user":
            break  # a tool result or your prompt: the reply comes after it
        content = entry.get("message", {}).get("content")
        if isinstance(content, list):
            texts[:0] = [b.get("text", "") for b in content if b.get("type") == "text"]
    text = "\n".join(texts).strip()
    return text or None


def last_reply(event):
    """Start of Claude's final reply, as plain text ("" if not available)."""
    text = event.get("last_assistant_message") or ""
    if not text and event.get("transcript_path"):
        # the transcript is written a moment after the reply, so wait briefly
        for _ in range(12):
            text = final_text(event["transcript_path"])
            if text:
                break
            time.sleep(0.25)
        text = text or ""
    # markdown -> plain: drop code fences, emphasis/code marks, heading and
    # list markers, and keep only link text
    text = re.sub(r"```.*?```", " ", text, flags=re.S)
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", text)
    text = re.sub(r"^\s*(#+|[-*+]|\d+\.|>|\|)\s*", "", text, flags=re.M)
    text = re.sub(r"[*_`|]+", "", text)
    text = " ".join(text.split())
    if len(text) > PREVIEW_LENGTH:
        text = text[:PREVIEW_LENGTH].rsplit(" ", 1)[0].rstrip(",.;:") + "…"
    return text


event = json.load(sys.stdin)
kind = sys.argv[1] if len(sys.argv) > 1 else "stop"

# The "waiting for your input" reminder follows every finished response after
# a minute idle; the Stop notification already covered that.
if kind == "attention" and event.get("notification_type") == "idle_prompt":
    sys.exit(0)

if session_focused():
    sys.exit(0)

if kind == "attention":
    summary = "Claude Code needs you"
    body = event.get("message") or "Waiting for your input"
    urgency = "critical"
else:
    summary = "Claude Code finished"
    body = last_reply(event) or "Done"
    urgency = "normal"

subprocess.run(["notify-send", "-a", "Claude Code", "-i", "claude-desktop",
                "-u", urgency, html.escape(summary, quote=False),
                html.escape(body, quote=False)])
