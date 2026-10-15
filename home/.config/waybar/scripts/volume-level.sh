#!/bin/sh
# Waybar: the "50%" next to the volume icon (custom/volume-level). Prints
# the volume with style classes for style.css: how many characters it takes
# ("two" = 5%, "three" = 50%, "four" = 100%), plus "muted" when muted, so the
# number can slide exactly its own width into the icon on mute. Updates the
# moment the volume, mute or output device changes (pactl subscribe).
print() {
    vol=$(pactl get-sink-volume @DEFAULT_SINK@ | awk -F/ 'NR == 1 { gsub(/[ %]/, "", $2); print $2 }')
    case ${#vol} in 1) width=two ;; 2) width=three ;; *) width=four ;; esac
    class="\"$width\""
    [ "$(pactl get-sink-mute @DEFAULT_SINK@)" = "Mute: yes" ] && class="$class, \"muted\""
    printf '{"text": "%s%%", "class": [%s]}\n' "$vol" "$class"
}

# watch for changes through a named pipe, so the watcher can be stopped
# along with this script
fifo=$(mktemp -u)
mkfifo "$fifo"
pactl subscribe > "$fifo" &
watcher=$!
exec 3< "$fifo"
rm "$fifo"
trap 'kill $watcher 2>/dev/null' EXIT
trap 'exit' HUP INT TERM

# stop once the bar reading this has gone (the bar starts scripts with the
# broken-pipe signal ignored, so a failed write alone wouldn't)
print || exit
while read -r event <&3; do
    case $event in
        *"on sink #"*|*"on server"*) print || exit ;;
    esac
done
