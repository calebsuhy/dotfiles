#!/bin/sh
# Waybar: CPU temperature and usage, e.g. "38°C 4%", updated every 2 seconds.
# The k10temp sensor is found by name, since its hwmon number can change
# between boots.
for d in /sys/class/hwmon/hwmon*; do
    [ "$(cat "$d/name")" = k10temp ] && sensor=$d/temp1_input
done
read -r _ u n s i w x y z _ < /proc/stat
prev_total=$((u + n + s + i + w + x + y + z)) prev_idle=$((i + w))
delay=0.5
while sleep $delay; do
    read -r _ u n s i w x y z _ < /proc/stat
    total=$((u + n + s + i + w + x + y + z)) idle=$((i + w))
    usage=$((100 * ((total - prev_total) - (idle - prev_idle)) / (total - prev_total)))
    prev_total=$total prev_idle=$idle
    # stop once the bar reading this has gone (the bar starts scripts with
    # the broken-pipe signal ignored, so a failed write alone wouldn't)
    echo "$(($(cat "$sensor") / 1000))°C $usage%" || exit
    delay=2
done
