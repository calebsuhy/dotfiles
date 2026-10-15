#!/usr/bin/env python3
"""Waybar: one workspace button. config.jsonc has custom/ws#1 ... custom/ws#5,
each running `workspace.py N`. Prints the button's state as JSON (class
"active" on the current workspace, which style.css underlines in red) and
prints it again whenever the active workspace changes, by listening on
Hyprland's event socket.

Waybar's own hyprland/workspaces module can't be used: with Hyprland 0.56 its
click sends the old command format, which Hyprland now rejects, so clicking a
workspace did nothing."""
import json
import os
import socket
import sys

number = sys.argv[1]
hypr = f"{os.environ['XDG_RUNTIME_DIR']}/hypr/{os.environ['HYPRLAND_INSTANCE_SIGNATURE']}"


def request(command):
    """Ask Hyprland something (like hyprctl does) and return the answer."""
    with socket.socket(socket.AF_UNIX) as sock:
        sock.connect(f"{hypr}/.socket.sock")
        sock.sendall(command.encode())
        answer = b""
        while chunk := sock.recv(65536):
            answer += chunk
    return answer.decode()


def show():
    active = json.loads(request("j/activeworkspace"))["id"]
    state = {"text": number, "class": ["active"] if str(active) == number else []}
    print(json.dumps(state), flush=True)  # fails, ending this, once the bar is gone


show()
# Hyprland announces events one per line, e.g. "workspace>>4"
CHANGES = (b"workspace>>", b"workspacev2>>", b"focusedmon>>")
with socket.socket(socket.AF_UNIX) as events:
    events.connect(f"{hypr}/.socket2.sock")
    pending = b""
    while chunk := events.recv(4096):
        pending += chunk
        *lines, pending = pending.split(b"\n")
        if any(line.startswith(CHANGES) for line in lines):
            show()
