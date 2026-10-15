#!/bin/sh
# Autolock warning (hypridle.conf): "show" pops up "Locking in 30 seconds"
# when you've been idle 4.5 minutes; "hide" takes it away again as soon as
# you move the mouse or press a key. The popup's number is kept in a file so
# "hide" closes exactly that popup. Lives in its own file because hypridle's
# config reads $ as its own variables.
id_file="${XDG_RUNTIME_DIR:-/tmp}/autolock-warning.id"

case "$1" in
show)
    notify-send -p -a autolock -i system-lock-screen \
        -h string:x-dunst-stack-tag:autolock \
        "Locking in 30 seconds" "Move the mouse or press a key to stay unlocked." \
        > "$id_file"
    ;;
hide)
    [ -s "$id_file" ] || exit 0
    gdbus call --session --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.CloseNotification \
        "$(cat "$id_file")" >/dev/null
    rm -f "$id_file"
    ;;
esac
