#!/bin/sh
# Starts Spotify with the "Casu" theme always in place. The launcher entry
# ~/.local/share/applications/spotify-launcher.desktop runs this instead of
# plain spotify-launcher. Spotify updates itself when it starts, which wipes
# the theme, so: let it update first without starting, re-apply the theme
# if the version changed since the last time, then start it.
state=~/.local/share/spotify-launcher/state.json
themed=~/.config/spicetify/themed-version

spotify-launcher --no-exec
version=$(grep -o '"version":"[^"]*"' "$state")
if [ "$version" != "$(cat "$themed" 2>/dev/null)" ]; then
    spicetify -q -n backup apply && echo "$version" > "$themed"
fi
exec spotify-launcher --skip-update "$@"
