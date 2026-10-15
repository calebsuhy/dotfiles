#!/bin/sh
# Pending updates (official repos + AUR), rechecked every 10 minutes and right
# away on USR1 (sent by updates-menu.sh when it opens and after an upgrade).
# Shows the count, or an empty line when there are none so the module
# disappears from the bar. The full list is saved for updates-menu.sh, so the
# menu opens instantly and always matches this count; each line is
# "name old -> new repo" or "name old -> new AUR".
cache=${XDG_CACHE_HOME:-$HOME/.cache}/waybar-updates
trap : USR1
while :; do
    # checkupdates exits 1 when it fails (e.g. offline; 2 means no updates):
    # keep the last list then rather than dropping to zero
    repo=$(checkupdates 2>/dev/null)
    if [ $? -ne 1 ]; then
        {
            [ -n "$repo" ] && printf '%s\n' "$repo" | sed 's/$/ repo/'
            yay -Qua 2>/dev/null | sed 's/$/ AUR/'
        } > "$cache.tmp"
        # swap in whole, so the menu never reads a half-written list
        mv "$cache.tmp" "$cache"
    fi
    n=$(grep -c . "$cache" 2>/dev/null) || n=0
    # stop once the bar reading this has gone (the bar starts scripts with
    # the broken-pipe signal ignored, so a failed write alone wouldn't)
    if [ "$n" -gt 0 ]; then echo "󰏗 $n"; else echo ""; fi || exit
    # wait is interrupted by USR1; then stop the leftover sleep
    sleep 600 & wait $!
    kill $! 2>/dev/null
done
