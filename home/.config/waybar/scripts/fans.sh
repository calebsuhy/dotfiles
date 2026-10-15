#!/bin/sh
# Waybar: CPU fan and GPU fan speeds in RPM, e.g. "1150 · 0", updated every
# 2 seconds. The GPU number is the average of the card's two fans (0 when the
# card is cool: it stops its fans until it warms up). The CPU fan comes from
# the motherboard's fan chip (driver it87, sensor name "it8689"; fan1 = the
# CPU_FAN header); until that driver is loaded it shows "–". The sensor is
# looked for by name every time, since its hwmon number can change between
# boots and the driver may be loaded after the bar starts.
cpu_fan() {
    for d in /sys/class/hwmon/hwmon*; do
        case $(cat "$d/name") in
            it86*|it87*) cat "$d/fan1_input" 2>/dev/null && return ;;
        esac
    done
    echo –
}

gpu_fan() {
    nvidia-settings -q GPUCurrentFanSpeedRPM -t 2>/dev/null |
        awk '{ sum += $1; n++ } END { if (n) printf "%d\n", sum / n; else print "–" }'
}

while :; do
    # stop once the bar reading this has gone (the bar starts scripts with
    # the broken-pipe signal ignored, so a failed write alone wouldn't)
    echo "$(cpu_fan) · $(gpu_fan)" || exit
    sleep 2
done
