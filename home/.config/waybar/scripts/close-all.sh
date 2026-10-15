#!/bin/sh
# Closes every open window on every workspace, the scratchpads too, gently:
# each one gets the same close request as Super+Shift+Q (like clicking its ×),
# so apps can save or ask about unsaved work. Then waits up to 8 seconds for
# them to go. Each window still open after that (e.g. a "Save changes?"
# dialog) gets its own notification, "Still open: App", that takes you to that
# window when clicked; the first one is also brought into view. Otherwise a
# notification says everything closed. None of these go into the bell's list
# (dunstrc [close-all] history_ignore). Run from the power menu's
# "Close all windows" (power-menu.sh), after it asks to confirm.

# open windows, one per line: address, app, title
windows() {
    hyprctl clients -j | python3 -c '
import json, sys
for c in json.load(sys.stdin):
    if c["mapped"]:
        print(c["address"], c["class"], c["title"], sep="\t")'
}

notify() {
    notify-send -a "Close all" -i window-close \
        -h string:x-dunst-stack-tag:close-all "$@"
}

total=$(windows | grep -c .)
[ "$total" -eq 0 ] && { notify "No windows are open"; exit; }

windows | cut -f1 | while read -r address; do
    hyprctl dispatch "hl.dsp.window.close({ window = \"address:$address\" })" >/dev/null
done

# wait for them to go (checking 4 times a second, for up to 8 seconds)
for _ in $(seq 32); do
    [ "$(windows | grep -c .)" -eq 0 ] && break
    sleep 0.25
done

left=$(windows)
if [ -z "$left" ]; then
    notify "Closed all $total windows"
    exit
fi

# Still open: one notification per window (up to 8), each waiting in the
# background for a click, which takes you to that window. Critical ones stay
# on screen until clicked or dismissed. (No stack tag: they'd replace each
# other.)
go_to() { hyprctl dispatch "hl.dsp.focus({ window = \"address:$1\" })" >/dev/null; }
tab=$(printf '\t')
printf '%s\n' "$left" | head -8 | while IFS="$tab" read -r address app title; do
    title=$(printf '%s' "$title" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
    (
        choice=$(notify-send -a "Close all" -i window-close -u critical \
            -A default="Go to window" --wait "Still open: $app" "$title")
        [ "$choice" = default ] && go_to "$address"
    ) &
done
count=$(printf '%s\n' "$left" | grep -c .)
[ "$count" -gt 8 ] && notify -u critical "…and $((count - 8)) more windows still open"
go_to "$(printf '%s\n' "$left" | head -1 | cut -f1)"
