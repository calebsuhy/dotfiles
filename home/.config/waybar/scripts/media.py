#!/usr/bin/env python3
"""Waybar "now playing" in the middle of the bar, in four parts (config.jsonc):

  media.py info          icon + "Artist – Title  2:50 / 3:03"; while paused
                         the icon is a pause symbol and style.css dims it all
  media.py button-prev   ⏮ button
  media.py button-play   ▶ / ⏸ button (shows what a click will do)
  media.py button-next   ⏭ button

What the clicks run: media.py previous | play-pause | next, and media.py
show (clicking the song) jumps to the Spotify workspace. Follows Spotify
first, else any other player (e.g. a video in Firefox). Pausing, playing
and song changes show the instant they happen (from "playerctl --follow",
however you paused: bar button, Spotify itself or a key); the time into the
song updates every second. Nothing shows when no player is open.
"""
import ctypes
import html
import json
import select
import signal
import subprocess
import sys

PLAYERS = "spotify,%any"
MAX_LENGTH = 70  # characters of "Artist – Title" (ends in … beyond that)
SPOTIFY_WORKSPACE = 4
LOOP_MODES = ("info", "button-prev", "button-play", "button-next")

# icon font symbols, by code (the symbols themselves get lost by some editors)
ICONS = {
    "spotify": "",
    "music": "\U000f075a",
    "pause": "\U000f03e4",
    "play": "\U000f040a",
    "prev": "\U000f04ae",
    "next": "\U000f04ad",
}


def playerctl(*args):
    result = subprocess.run(["playerctl", "-p", PLAYERS, *args],
                            capture_output=True, text=True)
    return result.stdout.strip() if result.returncode == 0 else ""


def icon(name):
    # same size and lowering as the icons written in config.jsonc
    return (f"<span font='FiraCode Nerd Font Mono 27px' rise='-3072'>"
            f"{ICONS[name]}</span>")


def button_icon(name):
    # the buttons are smaller (13px tall, just above the text's capitals);
    # at 18px their middle already lines up with the text's, so no lowering
    return f"<span font='FiraCode Nerd Font Mono 18px'>{ICONS[name]}</span>"


def info():
    status = playerctl("status")
    if status not in ("Playing", "Paused"):
        return {"text": ""}
    sep = "\x1f"
    fields = playerctl("metadata", "--format", sep.join([
        "{{playerName}}", "{{artist}}", "{{title}}",
        "{{duration(position)}}", "{{duration(mpris:length)}}"]))
    name, artist, title, position, length = (fields.split(sep) + [""] * 5)[:5]
    song = f"{artist} – {title}" if artist and title else title or artist
    if len(song) > MAX_LENGTH:
        song = song[:MAX_LENGTH - 1] + "…"
    if status == "Paused":
        mark = "pause"
    else:
        mark = "spotify" if name == "spotify" else "music"
    text = f"{icon(mark)} {html.escape(song, quote=False)}"
    if position:
        elapsed = f"{position} / {length}" if length else position
        text += f"  <span alpha='55%'>{elapsed}</span>"
    return {"text": text, "class": status.lower()}


def button(which):
    status = playerctl("status")
    if status not in ("Playing", "Paused"):
        return {"text": ""}
    if which == "play":
        which = "pause" if status == "Playing" else "play"
    return {"text": button_icon(which), "class": status.lower()}


def follow():
    """playerctl printing a line whenever the player plays, pauses or
    changes song. It's told to quit along with this script (prctl
    PDEATHSIG), so a restarted bar never leaves one behind."""
    libc = ctypes.CDLL("libc.so.6")
    return subprocess.Popen(
        ["playerctl", "-p", PLAYERS, "--follow", "metadata", "--format",
         "{{status}} {{title}}"],
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True,
        preexec_fn=lambda: libc.prctl(1, signal.SIGTERM))


def run(mode):
    make = info if mode == "info" else lambda: button(mode.split("-")[1])
    watcher = follow()
    last = None
    while True:
        out = json.dumps(make(), ensure_ascii=False)
        if out != last:
            try:
                print(out, flush=True)
            except BrokenPipeError:
                # the bar reading this has gone (it starts scripts with the
                # broken-pipe signal ignored, so this shows up as an error)
                watcher.terminate()
                sys.exit()
            last = out
        # wait up to a second (for the time into the song), or less if the
        # player changes; restart the watcher if it ever stops
        ready, _, _ = select.select([watcher.stdout], [], [], 1)
        if ready and not watcher.stdout.readline():
            watcher = follow()


mode = sys.argv[1] if len(sys.argv) > 1 else "info"
if mode in LOOP_MODES:
    run(mode)
elif mode in ("previous", "play-pause", "next"):
    playerctl(mode)
elif mode == "show":
    if playerctl("metadata", "--format", "{{playerName}}") == "spotify":
        subprocess.run(["hyprctl", "dispatch",
                        f"hl.dsp.focus({{ workspace = {SPOTIFY_WORKSPACE} }})"],
                       capture_output=True)
