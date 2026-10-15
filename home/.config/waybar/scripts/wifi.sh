#!/bin/sh
# Waybar Wi-Fi, in two parts that sit in a click-to-open drawer
# (config.jsonc "group/wifi"):
#   wifi.sh icon   the icon; crossed out when not connected
#   wifi.sh name   the network name ("Disconnected" / "Wi-Fi off" when not
#                  connected), which slides out next to the icon when it's
#                  clicked and back in on the next click; clicking the name
#                  opens the Wi-Fi menu (wifi-menu.sh)
# Both refresh every 2 seconds. The drawer starts closed whenever the bar
# (re)starts.
while :; do
    if [ "$(cat /sys/class/net/wlan0/operstate)" = up ]; then
        icon="" name=$(nmcli -t -g GENERAL.CONNECTION dev show wlan0)
    else
        # not connected: just the crossed-out icon; the slide-out says why,
        # and clicking it still opens the menu to connect
        icon="󰖪"
        if [ "$(nmcli radio wifi)" = enabled ]; then name=Disconnected; else name="Wi-Fi off"; fi
    fi
    # stop once the bar reading this has gone (the bar starts scripts with
    # the broken-pipe signal ignored, so a failed write alone wouldn't)
    case $1 in
        icon) echo "$icon" ;;
        name) echo "$name" ;;
    esac || exit
    sleep 2
done
