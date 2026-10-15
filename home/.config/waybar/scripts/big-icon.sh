#!/bin/sh
# Waybar: some bar scripts (updates, notifications, wifi) print their own icon
# as the first character of each line. Pipe them through this so that icon is
# drawn in the big icon font and lowered to line up with the text, exactly
# like the icons written in config.jsonc. The rest of the line is escaped so
# a "&" or "<" (e.g. in a Wi-Fi name) can't break the bar's text.
exec sed -u \
    -e 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' \
    -e "s/^\([^ ]\)/<span font='FiraCode Nerd Font Mono 27px' rise='-3072'>\1<\/span>/"
