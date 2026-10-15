#!/bin/sh
# Runs inside the "System upgrade" window that "Upgrade all" in the updates
# menu (updates-menu.sh) opens: a header with the number of updates, then
# yay -Syu in colour (pacman's Color, ILoveCandy and VerbosePkgLists in
# /etc/pacman.conf: colours, Pac-Man progress bars, old → new version table),
# then a ✓/✗ summary and "⏎ Close". The window floats in the middle of the
# screen like the scratchpads (window rule "system_upgrade" in hyprland.lua).
#
# Demo, to see it all without upgrading anything: from any terminal run
#   sh ~/.config/waybar/scripts/system-upgrade.sh --demo
# It opens the same window and only downloads three packages you already
# have (Firefox, Qt, bubblewrap) into a throwaway folder: same password
# prompt, version table and Pac-Man bars, but nothing is installed.
cache=${XDG_CACHE_HOME:-$HOME/.cache}/waybar-updates
demo_packages="firefox qt6-base bubblewrap"

# --demo typed in a terminal: open the upgrade window and run there, leaving
# the terminal free (UPGRADE_WINDOW marks the copy running in the window)
if [ "$1" = --demo ] && [ -z "$UPGRADE_WINDOW" ]; then
    UPGRADE_WINDOW=1 setsid -f alacritty --class system_upgrade \
        --title "System upgrade" -e sh "$0" --demo >/dev/null 2>&1
    exit
fi

# Desktop colours as 24-bit terminal colour codes
cyan=$(printf '\033[38;2;224;255;255m')
red=$(printf '\033[38;2;197;84;73m')
green=$(printf '\033[38;2;175;190;162m')
dim=$(printf '\033[2m')
bold=$(printf '\033[1m')
reset=$(printf '\033[0m')

# Faint divider across the whole window (the width comes from stty: tput
# answers 80 when it isn't printing to the window itself)
rule() {
    cols=$(stty size </dev/tty | cut -d' ' -f2)
    printf '%s%s%s\n' "$dim" "$(printf '%*s' "$cols" '' | sed 's/ /─/g')" "$reset"
}

# Header: the count the bar showed (yay may find a few more once it syncs)
if [ "$1" = --demo ]; then
    n=$(echo $demo_packages | wc -w)
    note="  ·  demo, nothing is installed"
else
    n=$(grep -c . "$cache" 2>/dev/null); n=${n:-0}
    note=
fi
word=updates; [ "$n" -eq 1 ] && word=update
printf '\n  %s󰏗  %sSystem upgrade%s  %s·  %s %s%s%s\n\n' \
    "$red" "$cyan$bold" "$reset" "$dim" "$n" "$word" "$note" "$reset"
rule
echo

# Ctrl+C stops yay but not this script, so the summary still shows. (A
# handler instead of "ignore": an ignored Ctrl+C would pass to yay too.)
trap : INT

if [ "$1" = --demo ]; then
    # download-only (-w) into a throwaway folder, so even the packages
    # already in pacman's own cache get downloaded and show a progress bar;
    # it must be readable by pacman's download user (alpm)
    demo_dir=$(mktemp -d)
    chmod 755 "$demo_dir"
    sudo pacman -Sw --cachedir "$demo_dir" $demo_packages
    status=$?
    rm -rf "$demo_dir" 2>/dev/null || sudo -n rm -rf "$demo_dir" 2>/dev/null
else
    # --answerclean/--answerdiff None: skip yay's "Packages to cleanBuild?"
    # and "Diffs to show?" questions (both default to none anyway)
    yay -Syu --answerclean None --answerdiff None
    status=$?
fi

echo
rule
echo
if [ "$status" -eq 0 ]; then
    printf '  %s✓  Upgrade finished%s\n' "$green$bold" "$reset"
    summary="Upgrade finished"
else
    printf '  %s✗  Upgrade stopped%s  %s(scroll up to see why)%s\n' \
        "$red$bold" "$reset" "$dim" "$reset"
    summary="Upgrade stopped"
fi
# The running kernel's modules are removed when a new kernel is installed
if [ ! -d "/usr/lib/modules/$(uname -r)" ]; then
    printf '  %s󰜉  Restart when you can: the kernel was updated%s\n' "$cyan" "$reset"
    summary="$summary · restart when you can (kernel updated)"
fi

# A notification too, if you've switched to another window in the meantime
if ! hyprctl activewindow -j | grep -q '"class": "system_upgrade"'; then
    notify-send -a "System upgrade" -i system-software-update "$summary"
fi

printf '\n  %s⏎%s  Close ' "$dim" "$reset"
read -r _
