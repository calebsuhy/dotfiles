#!/bin/sh
# Waybar bell for dunst, followed by how many notifications are unread
# (every one not yet removed from the list: on screen, in the history, or held
# back by do-not-disturb); no number when there are none. While
# do-not-disturb is on, the bell is crossed out.
# "notifications.sh toggle" (right-click) flips do-not-disturb and makes the
# running bell redraw immediately instead of at its next 1-second check.
if [ "$1" = toggle ]; then
    dunstctl set-paused toggle
    pkill -USR1 -f 'waybar/scripts/notifications\.sh$'
    exit
fi

trap : USR1
while :; do
    n=$(( $(dunstctl count displayed) + $(dunstctl count history) \
        + $(dunstctl count waiting) ))
    if [ "$(dunstctl is-paused 2>/dev/null)" = true ]; then bell=󰂛; else bell=󰂚; fi
    # stop once the bar reading this has gone (the bar starts scripts with
    # the broken-pipe signal ignored, so a failed write alone wouldn't)
    if [ "$n" -gt 0 ]; then echo "$bell $n"; else echo "$bell"; fi || exit
    # wait is interrupted by the USR1 a right-click sends
    sleep 1 & wait $!
done
