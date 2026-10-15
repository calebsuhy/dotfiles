#!/bin/sh
# Waybar power button: a rofi
# panel styled like the notification and updates menus, bottom-right above
# the button, 24px from the screen edge and the bar like the window gaps.
# Close all windows / Lock / Log out / Reboot / Shut down: Enter, "Select" or
# a click on a row picks one; Esc, "Close" or a click outside closes. All but
# Lock ask to confirm on a second screen ("⏎ Reboot · Esc Cancel"). Close all
# windows runs close-all.sh: every window on every workspace (scratchpads
# too) is asked to close, and a notification names any still open after 8s.
theme=~/.config/rofi/launchers/type-1/style-6.rasi

# If a power panel is already open, close it (and stop here); close any other
# rofi too, since only one can run at a time. (Usually the button can't even
# be clicked while a rofi menu is open: a click rule in hyprland.lua closes
# the menu instead, so this is a safety net.)
this_menu_open=$(pgrep -f '^rofi -dmenu .*button-ok')
pkill -x rofi
[ -n "$this_menu_open" ] && exit
for _ in $(seq 50); do pgrep -x rofi >/dev/null || break; sleep 0.02; done

# Shared look, one setting per line (rofi misreads a line that holds two
# quoted values). $1 = footer's left button, $2 = its action, $3 = right
# button, $4 = number of rows (0 hides the list).
style() {
    list=true; [ "$4" -eq 0 ] && list=false
    cat <<EOF
window { location: south east; anchor: south east;
    x-offset: -24px; y-offset: -24px; width: 320px;
    border: 2px solid; border-color: #E0FFFF; border-radius: 6px; }
element, textbox, scrollbar, button { border-radius: 0px; }
inputbar { children: [ "textbox-pad-l", "prompt", "textbox-pad-r" ]; }
textbox-pad-l, textbox-pad-r { expand: true; padding: 0px;
    background-color: transparent; }
prompt { padding: 5px 0px; expand: false; markup: true; }
mainbox { padding: 14px; spacing: 8px;
    children: [ "inputbar", "listview", "footer" ]; }
listview { enabled: $list; lines: $4; spacing: 4px; }
element { padding: 7px; background-color: transparent;
    text-color: transparent;
    children: [ "textbox-arrow", "element-text" ]; }
textbox-arrow { str: "❯";
    expand: false; padding: 0px 10px 0px 0px;
    background-color: transparent; text-color: inherit;
    vertical-align: 0.5; }
element-text { text-color: #FFFFFF; }
element selected.normal { background-color: transparent;
    text-color: #C55449; }
element normal.normal, element alternate.normal { background-color: transparent;
    text-color: transparent; }
footer { orientation: horizontal; expand: false; spacing: 0px;
    padding: 10px 0px 0px; background-color: transparent;
    border: 1px 0px 0px; border-color: #3A3A4A;
    children: [ "button-ok", "textbox-dot", "button-close" ]; }
button-ok, textbox-dot, button-close {
    expand: true; horizontal-align: 0.5; padding: 4px 6px; markup: true;
    background-color: transparent; text-color: #FFFFFF; }
button-ok { str: "$1";
    action: "$2";
    cursor: pointer; }
textbox-dot { str: "<span alpha='35%'>·</span>";
    expand: false; padding: 4px 0px; }
button-close { str: "$3";
    action: "kb-cancel";
    cursor: pointer; }
EOF
}

# Title with its icon on the left; an invisible copy after the words keeps
# the words themselves centred.
title() { printf "%s %s <span alpha='1'>%s</span>" "$1" "$2" "$1"; }

# Row icons use the fixed-width icon font so the labels line up.
# (This panel is found by "button-ok" in its style, which only it uses: a
# search on the icon characters themselves doesn't match.)
pick=$(printf '%s\n' \
    "<span font='FiraCode Nerd Font Mono' alpha='60%'>󰖭</span>   Close all windows" \
    "<span font='FiraCode Nerd Font Mono' alpha='60%'></span>   Lock" \
    "<span font='FiraCode Nerd Font Mono' alpha='60%'>󰍃</span>   Log out" \
    "<span font='FiraCode Nerd Font Mono' alpha='60%'>󰜉</span>   Reboot" \
    "<span font='FiraCode Nerd Font Mono' alpha='60%'></span>   Shut down" |
    rofi -dmenu -i -markup-rows -no-custom -format i -p "$(title  Power)" \
        -me-select-entry "" -me-accept-entry MousePrimary \
        -theme "$theme" -theme-str "$(style \
            "<span alpha='55%'>⏎</span> Select" kb-accept-entry \
            "<span alpha='55%'>Esc</span> Close" 5)" 2>/dev/null)

# Close all / Log out / Reboot / Shut down: a second screen to confirm. Enter is moved off "accept"
# (there's no row to pick) onto kb-custom-1, which makes rofi exit with
# status 10; the left footer button triggers the same. -no-click-to-exit:
# when the row was clicked, letting go of the mouse button lands outside this
# smaller screen, which would otherwise close it at once (a real click
# outside still closes it, via the click rule in hyprland.lua).
# It's fed one blank, hidden row: rofi crashes when a footer button is
# clicked on a menu with no rows at all.
confirm() {
    printf ' \n' |
    rofi -dmenu -no-click-to-exit -p "$(title "$1" "$2")" \
        -kb-accept-entry "Control+j" -kb-custom-1 "Return,KP_Enter" \
        -theme "$theme" -theme-str "$(style \
            "<span alpha='55%'>⏎</span> $3" kb-custom-1 \
            "<span alpha='55%'>Esc</span> Cancel" 0)" >/dev/null 2>&1
    [ $? -eq 10 ]
}

case "$pick" in
    0) n=$(hyprctl clients -j | grep -c '"mapped": true')
       word=windows; [ "$n" -eq 1 ] && word=window
       confirm 󰖭 "Close all $n $word?" "Close all" &&
           ~/.config/waybar/scripts/close-all.sh ;;
    1) loginctl lock-session ;;  # hypridle runs hyprlock
    2) confirm 󰍃 "Log out now?" "Log out" && hyprctl dispatch 'hl.dsp.exit()' ;;
    3) confirm 󰜉 "Reboot now?" Reboot && systemctl reboot ;;
    4) confirm  "Shut down now?" "Shut down" && systemctl poweroff ;;
esac
