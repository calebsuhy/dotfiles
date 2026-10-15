#!/bin/sh
# Clicked from the updates icon: lists pending updates (official repos + AUR)
# in rofi, styled like the notification list but opened bottom-left above the
# bar, where the icon is. Nothing in the list is selectable: Enter (or
# clicking "Upgrade all" at the bottom) opens a terminal that runs yay -Syu,
# and the bar's count refreshes once that terminal closes. Esc (or clicking
# "Close") closes.
# The list comes from the file updates.sh saves on every check, so the menu
# opens instantly and matches the bar's count.
theme=~/.config/rofi/launchers/type-1/style-6.rasi
cache=${XDG_CACHE_HOME:-$HOME/.cache}/waybar-updates

# If this menu is already open, close it (and stop here); close any other
# rofi too, since only one can run at a time. Usually the icon can't even be
# clicked while a rofi menu is open (a click rule in hyprland.lua closes the
# menu instead), so this is a safety net.
this_menu_open=$(pgrep -f '^rofi -dmenu .* Updates \(')
pkill -x rofi
[ -n "$this_menu_open" ] && exit
for _ in $(seq 50); do pgrep -x rofi >/dev/null || break; sleep 0.02; done

# 24px from the screen edge and the bar, like the gaps between windows. rofi
# is an overlay that already sits above the bar, so its offset counts from the
# bar's top edge.
x_offset=24px y_offset=-24px

# start a fresh check in the background; the bar's count (and the next time
# this menu opens) pick up anything new a moment later
pkill -USR1 -f 'waybar/scripts/updates\.sh$'

# "name old -> new" lines; AUR ones get a faint "AUR" tag
list=$(awk '{
    tag = ($5 == "AUR") ? "  <span alpha=\"55%\">AUR</span>" : ""
    printf "<b>%s</b>  <span alpha=\"55%%\">%s →</span> %s%s\n", $1, $2, $4, tag
}' "$cache" 2>/dev/null)
n=$(printf '%s' "$list" | grep -c .)

if [ "$n" -eq 0 ]; then
    list="<i>Everything is up to date</i>"
    # nothing to upgrade: the footer only offers Close
    footer="button-close"
else
    footer="button-upgrade\", \"textbox-dot\", \"button-close"
fi
# room for every row, up to 10 (scroll for more)
lines=$n; [ "$lines" -lt 1 ] && lines=1; [ "$lines" -gt 10 ] && lines=10

# Layout: centred title (the search box is hidden; an invisible copy of the
# icon after the words balances the one before them, so "Updates (n)" itself
# is centred, icon to its left), the list, then a footer
# under a faint divider with the key hints, which are clickable buttons too.
# The two hints split the footer into equal halves, each centred in its half,
# so the dot between them sits exactly in the middle.
# Enter is moved off "accept" (which would pick a row) onto kb-custom-1, which
# makes rofi exit with status 10 no matter what's highlighted; the "Upgrade
# all" button triggers the same. Rows are marked nonselectable (added in the
# pipe, as the shell can't keep the NUL byte that starts it in a variable)
# and the highlight is styled like any other row, so nothing looks selected.
# (No -no-custom: with it, rofi ignores Enter when no row is selectable.)
printf '%s\n' "$list" | sed 's/$/\x00nonselectable\x1ftrue/' |
rofi -dmenu -i -markup-rows -p "󰏗 Updates ($n) <span alpha='1'>󰏗</span>" \
    -kb-accept-entry "Control+j" -kb-custom-1 "Return,KP_Enter" \
    -me-select-entry "" -me-accept-entry "" \
    -theme "$theme" -theme-str "
        window { location: south west; anchor: south west;
                 x-offset: $x_offset; y-offset: $y_offset; width: 540px;
                 border: 2px solid; border-color: #E0FFFF; border-radius: 6px; }
        element, textbox, scrollbar, button { border-radius: 0px; }
        inputbar { children: [ \"textbox-pad-l\", \"prompt\", \"textbox-pad-r\" ]; }
        textbox-pad-l, textbox-pad-r { expand: true; padding: 0px;
                                      background-color: transparent; }
        prompt { padding: 5px 0px; expand: false; markup: true; }
        mainbox { padding: 14px; spacing: 8px;
                  children: [ \"inputbar\", \"listview\", \"footer\" ]; }
        listview { lines: $lines; spacing: 4px; }
        element { padding: 7px; children: [ \"element-text\" ]; }
        element, element selected.normal, element normal.normal, element alternate.normal, element normal.active, element selected.active {
            background-color: transparent; text-color: #FFFFFF; }
        footer { orientation: horizontal; expand: false; spacing: 0px;
                 padding: 10px 0px 0px; background-color: transparent;
                 border: 1px 0px 0px; border-color: #3A3A4A;
                 children: [ \"$footer\" ]; }
        button-upgrade, textbox-dot, button-close {
            expand: true; horizontal-align: 0.5; padding: 4px 6px; markup: true;
            background-color: transparent; text-color: #FFFFFF; }
        button-upgrade { str: \"<span alpha='55%'>⏎</span> Upgrade all\";
                         action: \"kb-custom-1\"; cursor: pointer; }
        textbox-dot { str: \"<span alpha='35%'>·</span>\"; expand: false; padding: 4px 0px; }
        button-close { str: \"<span alpha='55%'>Esc</span> Close\";
                       action: \"kb-cancel\"; cursor: pointer; }" >/dev/null

# exit status 10 = kb-custom-1 (Enter or the Upgrade all button)
if [ $? -eq 10 ] && [ "$n" -gt 0 ]; then
    alacritty --class system_upgrade --title "System upgrade" \
        -e sh ~/.config/waybar/scripts/system-upgrade.sh
    # ask the bar's updates.sh to recount now instead of in up to 10 minutes
    pkill -USR1 -f 'waybar/scripts/updates\.sh$'
fi
