#!/bin/sh
# Lock screen (hyprlock.conf): "Artist — Title" of the song playing in
# Spotify, or a blank when it's paused or closed (a space, so the label
# never falls back to its "Sample Text" placeholder). Lives in its own file
# because hyprlock's config reads {{ }} as maths, which breaks playerctl's
# format. & is escaped because hyprlock labels read their text as markup.
[ "$(playerctl -p spotify status 2>/dev/null)" = Playing ] || { echo " "; exit 0; }
playerctl -p spotify metadata --format '󰝚  {{artist}} — {{title}}' | sed 's/&/\&amp;/g'
