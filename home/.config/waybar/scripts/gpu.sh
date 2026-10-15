#!/bin/sh
# Waybar: Nvidia GPU temperature and usage, e.g. "32°C 1%". nvidia-smi's own
# loop (-l 2) reports every 2 seconds without restarting it each time.
nvidia-smi --query-gpu=temperature.gpu,utilization.gpu \
    --format=csv,noheader,nounits -l 2 |
    while IFS=', ' read -r temp usage; do
        # once the bar reading this has gone, stop, and stop nvidia-smi too
        # (the bar starts scripts with the broken-pipe signal ignored, so
        # neither would notice on its own). By then the bar has already ended
        # this script's main shell, so the nvidia-smi is left with the system
        # (pid 1) as its parent; a live one always has its gpu.sh as parent.
        echo "${temp}°C ${usage}%" || {
            pkill -P 1 -f '^nvidia-smi --query-gpu=temperature.gpu,utilization.gpu'
            exit
        }
    done
