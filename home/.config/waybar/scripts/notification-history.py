#!/usr/bin/env python3
"""Show recent dunst notifications in rofi (newest first, with app icons).
A left-click opens one: it does what clicking its popup does (e.g. Discord
switches to that chat), takes you to that app's window, marks it read and
closes the list. Delete or a middle-click marks one as read, which removes
it from the history without opening it, while the list stays open. Enter (or "Clear all" at the bottom) clears them
all; Esc (or "Close") closes. The bell counts what's left.

Run without arguments (the bell's left-click) it opens rofi, which then runs
this same file as a rofi "script mode": rofi calls it again for every key
press, with ROFI_RETV saying which, and redraws the list from its output in
place instead of closing the window."""
import html, json, os, re, subprocess, sys, time

THEME = os.path.expanduser("~/.config/rofi/launchers/type-1/style-6.rasi")
# Open in the bottom-right corner just above the bar, where dunst shows its
# popups, 24px from the screen edge and the bar like the gaps between windows.
# rofi is an overlay that already sits above the bar, so its offset counts
# from the bar's top edge.
# Smaller than the launcher it borrows its look from: narrower, and tighter
# padding (long rows end in "…"). The window fits its rows (up to 6, then it
# scrolls), so with nothing in it it's just the title and "All caught up". 6px rounded corners and a 2px light cyan
# border, like dunst's popups and focused windows, so it stands out
# from what's behind it. No search box: the top line is just the centred title.
# The highlighted row gets a red ❯ on its left instead of a red fill. Every
# row has the ❯, coloured by the row's text colour, which is see-through
# except on the highlighted row; the row's own text is always white.
X_OFFSET = Y_OFFSET = "-24px"
POSITION = ("window { location: south east; anchor: south east;"
            f" x-offset: {X_OFFSET}; y-offset: {Y_OFFSET}; width: 540px;"
            " border: 2px solid; border-color: #E0FFFF; border-radius: 6px; }"
            " element, textbox, scrollbar, button { border-radius: 0px; }"
            # empty stretchy boxes either side of the title push it to the middle
            ' inputbar { children: [ "textbox-pad-l", "prompt", "textbox-pad-r" ]; }'
            ' textbox-pad-l, textbox-pad-r { expand: true; padding: 0px;'
            " background-color: transparent; }"
            " prompt { padding: 5px 0px; expand: false; markup: true; }"
            " mode-switcher { enabled: false; }"
            " mainbox { padding: 14px; spacing: 8px; }"
            " listview { lines: 6; fixed-height: false; spacing: 4px; }"
            # the "All caught up" line (rofi's message box), centred
            " message { background-color: transparent; }"
            " textbox { background-color: transparent; horizontal-align: 0.5;"
            " padding: 8px 0px 4px; }"
            ' element { padding: 7px; background-color: transparent;'
            ' text-color: transparent;'
            ' children: [ "textbox-arrow", "element-icon", "element-text" ]; }'
            ' textbox-arrow { str: "❯"; expand: false; padding: 0px;'
            ' background-color: transparent; text-color: inherit;'
            ' vertical-align: 0.5; }'
            " element-text { text-color: #FFFFFF; }"
            " element selected.normal { background-color: transparent;"
            " text-color: #C55449; }"
            # unselected rows keep the arrow see-through
            " element normal.normal, element alternate.normal {"
            " background-color: transparent; text-color: transparent; }")


def footer(empty):
    """Theme for the footer, like the updates menu: a faint divider, then
    "⏎ Clear all · Esc Close" as two clickable halves with the dot exactly in
    the middle. With nothing to clear it only offers Close."""
    buttons = '"button-close"' if empty else '"button-clear", "textbox-dot", "button-close"'
    return (' mainbox { children: [ "inputbar", "message", "listview", "footer" ]; }'
            " footer { orientation: horizontal; expand: false; spacing: 0px;"
            " padding: 10px 0px 0px; background-color: transparent;"
            " border: 1px 0px 0px; border-color: #3A3A4A;"
            f" children: [ {buttons} ]; }}"
            " button-clear, textbox-dot, button-close {"
            " expand: true; horizontal-align: 0.5; padding: 4px 6px; markup: true;"
            " background-color: transparent; text-color: #FFFFFF; }"
            # Enter is kb-custom-2 (see the rofi command below)
            " button-clear { str: \"<span alpha='55%'>⏎</span> Clear all\";"
            ' action: "kb-custom-2"; cursor: pointer; }'
            " textbox-dot { str: \"<span alpha='35%'>·</span>\"; expand: false; padding: 4px 0px; }"
            " button-close { str: \"<span alpha='55%'>Esc</span> Close\";"
            ' action: "kb-cancel"; cursor: pointer; }')


def field(n, key):
    return n.get(key, {}).get("data", "")


def ago(timestamp_us):
    # dunst timestamps are microseconds on the monotonic clock
    s = max(0, int(time.monotonic() - timestamp_us / 1e6))
    if s < 60:
        return "just now"
    for unit, size in (("d", 86400), ("h", 3600), ("m", 60)):
        if s >= size:
            return f"{s // size}{unit} ago"


def plain(text):
    # dunst keeps markup in bodies; rofi rows need it stripped and escaped
    text = re.sub(r"<[^>]+>", "", text).replace("\n", " ")
    return html.escape(html.unescape(text).strip())


def rows():
    history = json.loads(subprocess.run(["dunstctl", "history"], capture_output=True,
                                        text=True).stdout or '{"data": [[]]}')["data"][0]
    lines = []
    for index, n in enumerate(history):
        app = plain(field(n, "appname"))
        if app == "notify-send":
            app = ""
        meta = " · ".join(x for x in (app, ago(field(n, "timestamp"))) if x)
        row = f"<b>{plain(field(n, 'summary'))}</b>  {plain(field(n, 'body'))}"
        row += f"  <span alpha='55%'>{meta}</span>"
        # info comes back to us in ROFI_INFO when this row is picked
        row += f"\0info\x1f{field(n, 'id')}:{index}"
        icon = field(n, "icon_path")
        lines.append(row + (f"\x1ficon\x1f{icon}" if icon else ""))
    return lines


def show(lines, select=0):
    # just the word, centred (no bell icon)
    print("\0prompt\x1fNotifications")
    if not lines:
        # empty: no rows, so the window shrinks to the title and this line.
        # An invisible copy of the icon after the text balances the one
        # before it, so the words themselves are centred, icon to their left.
        icon = "󱅫"
        print(f"\0message\x1f<span alpha='55%'>{icon}</span>  All caught up"
              f"  <span alpha='1'>{icon}</span>")
    print("\0markup-rows\x1ftrue")
    print("\0no-custom\x1ftrue")  # typing only searches; it never "picks"
    print("\0use-hot-keys\x1ftrue")  # pass Delete (kb-custom-1) through to us
    print(f"\0new-selection\x1f{max(0, min(select, len(lines) - 1))}")
    if lines:  # printing an empty string would still make one blank row
        print("\n".join(lines))


def reopen_when_closed():
    """rofi closes when a refresh leaves no rows, and can't shrink an open
    window to the empty view anyway, so once it has gone open a fresh one."""
    env = {k: v for k, v in os.environ.items() if not k.startswith("ROFI_")}
    subprocess.Popen(
        ["sh", "-c", 'while pgrep -x rofi >/dev/null; do sleep 0.02; done; exec "$0"',
         __file__], env=env, start_new_session=True,
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def dunstctl(*args):
    return subprocess.run(["dunstctl", *args], capture_output=True, text=True).stdout


def open_notification(nid):
    """A click on a row: do what clicking its popup does (its default
    action, e.g. Discord switches to that chat), take you to the app's
    window, and mark it read. dunst can only run the action of a
    notification on screen, picked by position, so it's put back on screen
    for a moment as the only one there (any popups showing move into the
    list), and running the action closes it again."""
    history = json.loads(dunstctl("history") or '{"data": [[]]}')["data"][0]
    n = next((n for n in history if str(field(n, "id")) == nid), None)
    if n is None:
        return
    displayed = lambda: int(dunstctl("count", "displayed").strip() or 0)
    if displayed():
        dunstctl("close-all")
    dunstctl("history-pop", nid)
    # it takes dunst a moment to show it; the action only works once it's up
    for _ in range(50):
        if displayed():
            break
        time.sleep(0.02)
    dunstctl("action", "0")
    # running the action closes it; make sure, then drop it from the history
    for _ in range(25):
        if not displayed():
            break
        time.sleep(0.02)
    else:
        dunstctl("close", nid)
    time.sleep(0.05)
    dunstctl("history-rm", nid)
    # the app's own window (e.g. "vesktop"), wherever it is; apps can't
    # always bring themselves forward, so do it for them
    app = field(n, "appname").lower()
    clients = json.loads(subprocess.run(["hyprctl", "clients", "-j"],
                                        capture_output=True, text=True).stdout or "[]")
    # best match first: the exact name ("vesktop"), then one ending in it
    # ("com.anthropic.Claude" for "Claude"), then one merely containing it,
    # so Claude Desktop's notifications don't open the Claude scratchpad
    def match(c):
        name = c["class"].lower()
        return 0 if name == app else 1 if name.endswith("." + app) else 2
    window = min((c for c in clients if app and app in c["class"].lower()),
                 key=match, default=None)
    # Claude Code notifications name their session's window (the Claude
    # scratchpad or a terminal) in a note left by ~/.claude/hooks/desktop-notify.py
    note = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "claude-notify", nid)
    try:
        with open(note) as f:
            address = f.read().strip()
        os.remove(note)
        window = next((c for c in clients if c["address"] == address), None)
    except OSError:
        pass
    if window:
        subprocess.run(["hyprctl", "dispatch",
                        f'hl.dsp.focus({{ window = "address:{window["address"]}" }})'],
                       capture_output=True)


# ROFI_RETV: a click on a row, Delete or middle-click (-kb-custom-1), Enter (-kb-custom-2)
CLICK, DELETE, CLEAR_ALL = 1, 10, 11

def close_open_menus():
    """If this list is already open, close it (and stop here); close any
    other rofi too, since only one can run at a time. Usually the bell can't
    even be clicked while a rofi menu is open (a click rule in hyprland.lua
    closes the menu instead), so this is a safety net."""
    running = lambda *args: subprocess.run(["pgrep", *args], capture_output=True).returncode == 0
    this_list_open = running("-f", "^rofi -show notifications ")
    subprocess.run(["pkill", "-x", "rofi"])
    if this_list_open:
        sys.exit()
    for _ in range(50):  # wait (up to 1s) for the other rofi to be gone
        if not running("-x", "rofi"):
            break
        time.sleep(0.02)


if "ROFI_RETV" not in os.environ:
    # Launched from the bell: open rofi with this file as its mode script.
    close_open_menus()
    os.execvp("rofi", [
        "rofi", "-show", "notifications", "-modi", f"notifications:{__file__}",
        "-show-icons", "-i",
        # Delete normally deletes text in the search box; keep Ctrl+D for that.
        # A middle-click does the same as Delete. rofi only passes keys and
        # clicks on to us for the highlighted row, so the highlight follows
        # the mouse (hover-select) to make that the row under the pointer.
        "-kb-remove-char-forward", "Control+d", "-kb-custom-1", "Delete,MouseMiddle",
        "-hover-select",
        # Enter clears all (kb-custom-2) instead of picking the highlighted row
        "-kb-accept-entry", "Control+j", "-kb-custom-2", "Return,KP_Enter",
        # one left-click on a row opens it (normally it only highlights)
        "-me-select-entry", "", "-me-accept-entry", "MousePrimary",
        # (one setting per line: rofi misreads a line holding two quoted values)
        "-theme", THEME, "-theme-str",
        (POSITION + footer(empty=not rows())).replace("; ", ";\n").replace("} ", "}\n")])

retv = int(os.environ["ROFI_RETV"])
info = os.environ.get("ROFI_INFO", "")
if retv == CLEAR_ALL:
    # Enter or "Clear all": empty the history; the list reopens empty
    if rows():
        subprocess.run(["dunstctl", "history-clear"])
        reopen_when_closed()  # printing nothing closes this rofi
elif retv == 0 or not info:
    show(rows())  # first draw
elif retv == CLICK:
    # open it; printing nothing closes this rofi
    open_notification(info.split(":")[0])
elif retv == DELETE:
    # mark as read = remove it; the list stays open
    nid, index = info.split(":")
    subprocess.run(["dunstctl", "history-rm", nid])
    left = rows()
    if left:
        show(left, select=int(index))  # same spot: the next one moves up into it
    else:
        reopen_when_closed()  # printing nothing closes this rofi
