#!/bin/sh
# Waybar Wi-Fi menu, opened by clicking the network name that slides out of
# the Wi-Fi icon (config.jsonc "custom/wifi-name"). A rofi panel styled like
# the power and notification menus, bottom-right above the bar, 24px from the
# screen edge and the bar. Lists the networks in range, the one you're on
# first (✓), then strongest first, with signal bars and a lock on the ones
# that need a password; the last row turns Wi-Fi off (or on).
# Picking a network connects to it: one you've used before connects straight
# away, a new one with a lock asks for its password on a second screen.
# Picking the one you're on asks to disconnect. A notification says how it
# went. Esc, "Close" or a click outside closes.
theme=~/.config/rofi/launchers/type-1/style-6.rasi
tab=$(printf '\t')

# Icons, written as byte codes (the icon font's own symbols get lost by some
# editors): Wi-Fi, Wi-Fi off, signal bars 1-4, radio off, lock
i_wifi=$(printf '\357\207\253')
i_wifi_off=$(printf '\363\260\226\252')
i_bars1=$(printf '\363\260\244\237')
i_bars2=$(printf '\363\260\244\242')
i_bars3=$(printf '\363\260\244\245')
i_bars4=$(printf '\363\260\244\250')
i_radio_off=$(printf '\363\260\244\255')
i_lock=$(printf '\357\200\243')

# If this menu is already open, close it (and stop here); close any other
# rofi too, since only one can run at a time. (Found by "button-connect" in
# its style, which only this menu uses.)
this_menu_open=$(pgrep -f '^rofi -dmenu .*button-connect')
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
    x-offset: -24px; y-offset: -24px; width: 420px;
    border: 2px solid; border-color: #E0FFFF; border-radius: 6px; }
element, textbox, scrollbar, button { border-radius: 0px; }
inputbar { children: [ "textbox-pad-l", "prompt", "textbox-pad-r" ]; }
textbox-pad-l, textbox-pad-r { expand: true; padding: 0px;
    background-color: transparent; }
prompt { padding: 5px 0px; expand: false; markup: true; }
mainbox { padding: 14px; spacing: 8px;
    children: [ "inputbar", "listview", "footer" ]; }
listview { enabled: $list; lines: $4; spacing: 4px; scrollbar: false; }
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
    children: [ "button-connect", "textbox-dot", "button-close" ]; }
button-connect, textbox-dot, button-close {
    expand: true; horizontal-align: 0.5; padding: 4px 6px; markup: true;
    background-color: transparent; text-color: #FFFFFF; }
button-connect { str: "$1";
    action: "$2";
    cursor: pointer; }
textbox-dot { str: "<span alpha='35%'>·</span>";
    expand: false; padding: 4px 0px; }
button-close { str: "$3";
    action: "kb-cancel";
    cursor: pointer; }
EOF
}

# The password screen: the same look, with the network as its title and a
# password box (typing shows dots) instead of a list
password_style() {
    style "<span alpha='55%'>⏎</span> Connect" kb-accept-custom \
        "<span alpha='55%'>Esc</span> Cancel" 0
    cat <<EOF
mainbox { children: [ "message", "inputbar", "listview", "footer" ]; }
message { padding: 5px 0px; background-color: transparent; border: 0px; }
textbox { horizontal-align: 0.5; }
inputbar { children: [ "entry" ]; padding: 7px 10px;
    border: 1px solid; border-color: #3A3A4A; border-radius: 6px; }
entry { placeholder: "Password"; placeholder-color: #8A8A99;
    horizontal-align: 0; }
EOF
}

# Title with its icon on the left; an invisible copy after the words keeps
# the words themselves centred.
title() { printf "%s %s <span alpha='1'>%s</span>" "$1" "$2" "$1"; }

# Markup-safe text (a "&" or "<" in a network name)
escape() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

# A notification about the connection; each one replaces the last
notify() {
    notify-send -a "Wi-Fi" -i network-wireless \
        -h string:x-dunst-stack-tag:wifi-menu "$@"
}

# A second screen to confirm (like the power menu's). Enter is moved off
# "accept" onto kb-custom-1 (exit status 10); the left footer button
# triggers the same. It's fed one blank, hidden row: rofi crashes when a
# footer button is clicked on a menu with no rows. -no-click-to-exit: the
# release of the click that picked the row lands outside this smaller
# screen, which would otherwise close it at once.
confirm() {
    printf ' \n' |
    rofi -dmenu -no-click-to-exit -p "$(title "$1" "$2")" \
        -kb-accept-entry "Control+j" -kb-custom-1 "Return,KP_Enter" \
        -theme "$theme" -theme-str "$(style \
            "<span alpha='55%'>⏎</span> $3" kb-custom-1 \
            "<span alpha='55%'>Esc</span> Cancel" 0)" >/dev/null 2>&1
    [ $? -eq 10 ]
}

# The saved connection (if any) for a network name
saved_profile() {
    nmcli -t -f NAME,TYPE con show | while IFS=: read -r name type; do
        [ "$type" = 802-11-wireless ] || continue
        [ "$(nmcli -g 802-11-wireless.ssid con show "$name")" = "$1" ] &&
            { echo "$name"; break; }
    done
}

connect() {
    ssid=$1 security=$2
    profile=$(saved_profile "$ssid")
    if [ -n "$profile" ]; then
        notify "Connecting to $ssid…"
        nmcli -w 20 con up id "$profile" >/dev/null 2>&1
    elif [ -z "$security" ] || [ "$security" = -- ]; then
        notify "Connecting to $ssid…"
        nmcli -w 20 dev wifi connect "$ssid" >/dev/null 2>&1
    else
        # Enter / "Connect" returns what was typed (kb-accept-custom);
        # the hidden row is only there to avoid rofi's no-rows crash
        password=$(printf ' \n' |
            rofi -dmenu -password -no-click-to-exit \
                -mesg "$(title "$i_lock" "$(escape "$ssid")")" \
                -kb-accept-entry "Control+j" -kb-accept-custom "Return,KP_Enter" \
                -theme "$theme" -theme-str "$(password_style)" 2>/dev/null)
        [ -n "$password" ] || exit
        notify "Connecting to $ssid…"
        if ! nmcli -w 20 dev wifi connect "$ssid" password "$password" >/dev/null 2>&1; then
            # don't keep a saved connection with a wrong password
            nmcli con delete id "$ssid" >/dev/null 2>&1
            notify -u critical "Couldn't connect to $ssid" "Wrong password?"
            exit
        fi
    fi
    if [ "$(nmcli -t -g GENERAL.CONNECTION dev show wlan0)" ]; then
        notify "Connected to $ssid"
    else
        notify -u critical "Couldn't connect to $ssid"
    fi
}

# Ask for a fresh scan in the background (the list below uses the last one,
# so the menu opens at once; the next opening sees the new scan)
nmcli dev wifi rescan >/dev/null 2>&1 &

# One line per network name: signal, "*" if it's the one in use, security,
# name. A name seen from several access points keeps its strongest signal;
# hidden networks (no name) are skipped. nmcli -t escapes ":" in names.
radio=$(nmcli radio wifi)
nets=
if [ "$radio" = enabled ]; then
    nets=$(nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan no 2>/dev/null |
        awk -F: -v OFS="$tab" '{
            ssid = substr($0, length($1) + length($2) + length($3) + 4)
            gsub(/\\:/, ":", ssid); gsub(/\\\\/, "\\", ssid)
            if (ssid == "") next
            if (!(ssid in best) || $2 + 0 > best[ssid]) { best[ssid] = $2 + 0; sec[ssid] = $3 }
            if ($1 == "*") cur[ssid] = "*"
        }
        END { for (s in best) print best[s], (s in cur) ? "*" : "-", sec[s], s }' |
        sort -t "$tab" -k2,2 -k1,1nr)
fi

# Rows: signal bars, name, then ✓ (the one you're on) or a lock
rows=$(printf '%s\n' "$nets" | awk -F "$tab" \
    -v b1="$i_bars1" -v b2="$i_bars2" -v b3="$i_bars3" -v b4="$i_bars4" -v lock="$i_lock" '
    $4 != "" {
        bars = ($1 >= 75) ? b4 : ($1 >= 50) ? b3 : ($1 >= 25) ? b2 : b1
        name = $4
        gsub(/&/, "\\&amp;", name); gsub(/</, "\\&lt;", name); gsub(/>/, "\\&gt;", name)
        mark = ""
        if ($2 == "*") mark = "✓"
        else if ($3 != "" && $3 != "--")
            mark = "<span font=\"FiraCode Nerd Font Mono\" alpha=\"60%\">" lock "</span>"
        printf "<span font=\"FiraCode Nerd Font Mono\" alpha=\"60%%\">%s</span>   %-24s %s\n", bars, name, mark
    }')
if [ "$radio" = enabled ]; then
    toggle="<span font='FiraCode Nerd Font Mono' alpha='60%'>$i_radio_off</span>   Turn Wi-Fi off"
else
    toggle="<span font='FiraCode Nerd Font Mono' alpha='60%'>$i_wifi</span>   Turn Wi-Fi on"
fi
count=$(printf '%s' "$rows" | grep -c .)
lines=$((count + 1)); [ "$lines" -gt 10 ] && lines=10

# Title: the network you're on
current=$(nmcli -t -g GENERAL.CONNECTION dev show wlan0 2>/dev/null)
if [ -n "$current" ]; then
    heading=$(title "$i_wifi" "$(escape "$current")")
elif [ "$radio" = enabled ]; then
    heading=$(title "$i_wifi_off" "Not connected")
else
    heading=$(title "$i_wifi_off" "Wi-Fi off")
fi

pick=$( { [ -n "$rows" ] && printf '%s\n' "$rows"; printf '%s\n' "$toggle"; } |
    rofi -dmenu -i -markup-rows -no-custom -format i -p "$heading" \
        -me-select-entry "" -me-accept-entry MousePrimary \
        -theme "$theme" -theme-str "$(style \
            "<span alpha='55%'>⏎</span> Connect" kb-accept-entry \
            "<span alpha='55%'>Esc</span> Close" "$lines")" 2>/dev/null)
[ -n "$pick" ] || exit

# The last row: Wi-Fi off / on
if [ "$pick" -eq "$count" ]; then
    if [ "$radio" = enabled ]; then nmcli radio wifi off; else nmcli radio wifi on; fi
    exit
fi

line=$(printf '%s\n' "$nets" | sed -n "$((pick + 1))p")
in_use=$(printf '%s' "$line" | cut -f2)
security=$(printf '%s' "$line" | cut -f3)
ssid=$(printf '%s' "$line" | cut -f4-)
if [ "$in_use" = "*" ]; then
    confirm "$i_wifi_off" "Disconnect from $(escape "$ssid")?" Disconnect &&
        nmcli dev disconnect wlan0 >/dev/null 2>&1 &&
        notify "Disconnected from $ssid"
else
    connect "$ssid" "$security"
fi
