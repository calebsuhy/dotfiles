# dotfiles

My Arch Linux desktop: **Hyprland** (a Wayland window manager that tiles
windows side by side) with a custom **Waybar** bar, **rofi** menus and
**dunst** notifications, all in one dark red/white look ("Casu").

The 2024 bspwm/X11 setup lives on the [`bspwm-2024`](../../tree/bspwm-2024) branch.

Machine it was built on: Ryzen 7 7800X3D, Gigabyte B650 AORUS ELITE AX,
NVIDIA RTX 4070 SUPER (`nvidia-open` driver), one 2560x1440 monitor at 165 Hz.

---

## What's in this repo

The folders mirror where the files live on the computer:

| Folder | Goes to | Needs sudo |
| --- | --- | --- |
| `home/` | your home folder (`~`) | no |
| `etc/` | `/etc` (system-wide settings) | yes |
| `boot/` | `/boot` (the GRUB boot menu theme) | yes |
| `firefox/` | your Firefox profile folder (its name is random, so it's copied by hand, see step 6) | no |
| `packages/pacman.txt` | list of programs installed from the official Arch repos | – |
| `packages/aur.txt` | list of programs installed from the AUR (community packages, built with `yay`) | – |

### Home folder (`home/`)

| Path | What it is |
| --- | --- |
| `.config/hypr/hyprland.lua` | Hyprland's main settings: monitor, look, animations, window rules, scratchpads, autostart |
| `.config/hypr/keybinds.lua` | All keyboard shortcuts (table below) |
| `.config/hypr/hyprlock.conf` | Lock screen look |
| `.config/hypr/hypridle.conf` + `autolock-warning.sh` | Locks after 5 minutes idle, with a warning popup 30 s before |
| `.config/hypr/hyprpaper.conf` | Wallpaper (`~/Pictures/wallpaper.jpg`) |
| `.config/hypr/now-playing.sh` | Song line shown on the lock screen |
| `.config/waybar/` | The bar: `config.jsonc` (what's on it), `style.css` (how it looks), `scripts/` (every module and menu) |
| `.config/rofi/` | Only the parts in use: `config.rasi`, `colors/casu.rasi` and `launchers/type-1/` (launcher + the `style-6` theme all menus borrow). Originally from [adi1090x/rofi](https://github.com/adi1090x/rofi) |
| `.config/dunst/dunstrc` | Notification popups |
| `.config/alacritty/alacritty.toml` | Terminal |
| `.config/zathura/zathurarc` | PDF viewer: background, status bar and command line in the bar colour |
| `.config/qt6ct/`, `.config/kdeglobals`, `.local/share/color-schemes/Casu.colors` | Dark Casu colours for Qt/KDE apps (Dolphin, Flameshot settings) |
| `.config/gtk-3.0/`, `.config/gtk-4.0/` | Dark theme, Papirus icons, Bibata cursor and Iosevka 11 for GTK apps |
| `.config/fontconfig/fonts.conf` | Makes Iosevka the default font for every app that doesn't pick its own (Firefox keeps its original fonts: FreeSans for web pages, Adwaita Sans for its menus) |
| `.local/share/fonts/` | Hand-installed fonts: Iosevka Nerd Font (lock screen song line), JetBrains Mono Nerd Font, Grape Nuts, feather icons |
| `.config/wireplumber/wireplumber.conf.d/51-yeti-soft-volume.conf` | Smooth volume for the Blue Yeti (see audio note below) |
| `.config/spicetify/` | Spotify theme "Casu" + `spotify-themed.sh` wrapper |
| `.local/share/applications/spotify-launcher.desktop` | Makes the Spotify menu entry start the themed version |
| `.config/vesktop/settings/` | Discord (Vesktop) custom CSS and settings |
| `.config/nvim/` | Neovim (vim-plug + coc.nvim completion). Also ngspice support: `.cir`/`.ckt` files open as SPICE, extra highlighting in `after/syntax/spice.vim`, and about 40 netlist templates in `snippets/spice.snippets` (Tab picks from the menu, Enter (or Ctrl+Y) accepts, Tab jumps between fields) |
| `.config/flameshot/` | Screenshot tool settings |
| `.config/mimeapps.list` | Which app opens which file type |
| `.claude/` | Claude Code: global instructions, settings, and the desktop notification hook |
| `.zshrc` | Shell |
| `Pictures/wallpaper.jpg` | Wallpaper |

### System files (`etc/`)

| File | What it does |
| --- | --- |
| `ly/config.ini` | ly, the text-mode login screen (colours, big clock) |
| `pam.d/ly` | Unlocks the GNOME keyring automatically when you log in (saved Wi-Fi/app passwords) |
| `pacman.conf` | Coloured pacman output, `ILoveCandy`, 5 parallel downloads, verbose package lists |
| `xdg/reflector/reflector.conf` | Reflector settings: every week it rebuilds `/etc/pacman.d/mirrorlist` with the 10 fastest of the 20 most up-to-date US download servers (HTTPS only), so updates stay fast |
| `makepkg.conf` | `!debug` in OPTIONS so AUR builds don't make extra `-debug` packages |
| `modules-load.d/it87.conf` + `modprobe.d/it87.conf` | Loads the motherboard's fan-sensor driver (it87) so the bar can show CPU fan speed |
| `default/grub` | GRUB boot menu settings: uses the WinTux theme, 2560×1440, 30-second countdown, starts on the neutral entry, looks for Windows (os-prober), and the `nvidia_drm.modeset=1` boot option |
| `grub.d/09_wintux_menu` | Lays the boot menu out left to right (Advanced Linux, Linux, neutral, Windows, UEFI settings) so the arrow keys move between the two hands. It switches off the stock `10_linux` and prints its entries itself, in that order |
| `grub.d/10_linux`, `grub.d/30_uefi-firmware` | The stock GRUB scripts with one small edit each (`--class gnu-linux-adv` / `--class efi`), which tells the theme which picture to show for "Advanced options" and "UEFI settings" |

### Firefox (`firefox/`)

| File | What it does |
| --- | --- |
| `user.js` | Switches on the hidden setting that lets Firefox load the two style files below |
| `chrome/userChrome.css` | Firefox's frame (tab strip, toolbar, menus, panels, sidebar) in the bar colour `#0F0F17`; address bar, search fields and the selected tab one shade lighter (`#1A1A26`). Uses Firefox 158's colour names, which change between versions |
| `chrome/userContent.css` | The new tab / home page and blank tabs in the same colours |

### Boot menu theme (`boot/`)

| File | What it does |
| --- | --- |
| `grub/themes/win-tux-dualboot-fullscreen/` | The WinTux GRUB theme: two wireframe hands, Tux on the left and the Windows logo on the right. The hand for the highlighted entry lights up (one picture per entry in `icons/`); the neutral entry in the middle shows both dimmed |

---

## Features

### Keyboard shortcuts (Super = Windows key)

| Keys | Action |
| --- | --- |
| Super + Enter | Terminal (Alacritty) |
| Super + Space | App launcher |
| Super + S | Scratchpad terminal (a floating terminal that slides in/out) |
| Super + C | Claude scratchpad: a floating terminal running Claude Code. It starts a **fresh conversation** whenever the window is created (first Super+C after login, or after closing it with Super+Shift+Q); older ones are still under `claude --resume`. Exiting Claude leaves a normal shell |
| Super + P | Screenshot of a selected area (saved to `~/Pictures/captures/`) |
| Super + M | Lock screen |
| Super + Shift + Q | Close window |
| Super + Shift + E | Log out |
| Super + Shift + Escape | Reload Hyprland config |
| Super + Shift + R | Reload config and restart the bar |
| Super + H/J/K/L | Focus left/down/up/right |
| Super + Shift + H/J/K/L | Swap window in that direction |
| Super + Ctrl + H/J/K/L | Open the next window on that side (with a short popup saying which side) |
| Super + Alt (+ Shift) + H/J/K/L | Grow (shrink) a window |
| Super + arrows | Move a floating window |
| Super + 1-0 | Go to workspace 1-10 |
| Super + Shift + 1-0 | Send window to workspace 1-10 |
| Super + T / Super + Shift + T / Super + F | Tiled / floating / fullscreen |
| Super + left-drag / right-drag | Move / resize a window with the mouse |
| Mouse thumb button | In terminals: taps Space (Claude Code voice input). Elsewhere it's still "back" |

Caps Lock acts as Escape. Key repeat: 175 ms delay, 60 per second.

### The bar (bottom of the screen)

- **Left:** workspaces 1-5 (firefox, claude, terminals, spotify, discord) with a red underline on the active one; Claude session count; CPU temperature and usage; GPU; **fans** ("CPU rpm · GPU rpm", needs the it87 files in `etc/`); memory; disk (space used on `/` and how full it is); **updates** count.
- **Centre, now playing:** artist, title and time of the current song (Spotify first, else any player), dims while paused, with previous/play/next buttons. Clicking the song jumps to the Spotify workspace.
- **Right:** network speed; **Wi-Fi drawer** (click the icon to slide the network name out, click the name for the Wi-Fi menu); notification **bell**; tray; **volume** (scroll to change, click to mute: the icon slides over the number); **clock drawer** (click to slide the full date out); **power** button.
- No hover tooltips anywhere.

### Menus (all rofi, same look; click outside to close)

- **Launcher** (Super+Space): apps, with a styled error popup if something fails to start.
- **Notifications** (click the bell): click a notification to re-open it and jump to its app; Delete or a middle-click marks one read without opening it (the highlight follows the mouse); Enter / "Clear all" clears everything. Middle-click the bell clears history, right-click toggles do-not-disturb.
- **Updates** (click the updates count): lists pending updates (AUR ones tagged), with a scrollbar when there are more than 10; the wheel or arrow keys move a red ❯ through the list. "Upgrade all" opens a floating terminal that runs `yay -Syu` with a summary at the end (and a restart hint if the kernel changed). Test without installing anything: `sh ~/.config/waybar/scripts/system-upgrade.sh --demo`.
- **Wi-Fi** (click the network name): networks sorted by signal, connect, enter a password for new secured networks, disconnect, turn Wi-Fi on/off.
- **Power**: Close all windows / Lock / Log out / Reboot / Shut down (all but Lock ask to confirm).
  - **Close all windows** asks "Close all N windows?", then politely closes every window on every workspace (scratchpads too), waits up to 8 s, and for any window that's still open (e.g. unsaved work) shows a "Still open: App" notice you can click to jump to it.

### Other touches

- Notifications (dunst) appear bottom-right; left-click = open, middle = dismiss, right = dismiss all.
- Claude Code pops up a desktop notification when it finishes or needs you, but **only when its window isn't focused** (`.claude/hooks/desktop-notify.py`). Clicking the notification, or its entry in the bell list after it has timed out, takes you back to that session (the Claude scratchpad slides in, or its terminal gets focused).
- Clicking an app's notification (Claude Desktop, Discord, ...) can bring that app's window to the front (`focus_on_activate` in `hyprland.lua`).
- The GRUB boot menu is the WinTux theme: pick Linux or Windows by moving left or right between two hands. It starts on the neutral entry in the middle; if the 30-second countdown runs out there, Linux boots.
- Spotify, Discord (Vesktop), Dolphin and other Qt/KDE apps, the lock screen and the login screen all use the same Casu colours.

---

## Restoring on a fresh Arch install

### 1. Base packages

```sh
git clone https://github.com/calebsuhy/dotfiles.git ~/dotfiles
sudo pacman -S --needed - < ~/dotfiles/packages/pacman.txt
```

`pacman.txt` includes machine-specific bits (`nvidia-open`, `amd-ucode`, `grub`); drop any that don't fit the new machine.

### 2. AUR packages (via yay)

```sh
git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
makepkg -si -D /tmp/yay-bin
yay -S --needed - < ~/dotfiles/packages/aur.txt
```

### 3. Copy your own config files

```sh
cp -a ~/dotfiles/home/. ~/
```

This overwrites existing files of the same name. Shell extras that aren't in the repo:

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
chsh -s /usr/bin/zsh
```

### 4. System files (needs sudo)

Compare before overwriting, since a newer Arch may ship newer versions of some of these files: especially `pacman.conf`, `makepkg.conf`, and the two edited GRUB scripts `grub.d/10_linux` and `grub.d/30_uefi-firmware`. If GRUB has changed those two, keep the new machine's copies (delete them from `~/dotfiles/etc/grub.d/` before copying) and just redo the one-word edit in each: add `--class gnu-linux-adv` to the "Advanced options" `submenu` line in `10_linux`, and `--class efi` to the `menuentry` line in `30_uefi-firmware`. Also check `GRUB_CMDLINE_LINUX_DEFAULT` in `etc/default/grub` still suits the machine (`nvidia_drm.modeset=1` is for an Nvidia card).

```sh
sudo diff /etc/pacman.conf ~/dotfiles/etc/pacman.conf
sudo diff /etc/grub.d/10_linux ~/dotfiles/etc/grub.d/10_linux
sudo diff /etc/grub.d/30_uefi-firmware ~/dotfiles/etc/grub.d/30_uefi-firmware
sudo cp -r --preserve=mode,timestamps ~/dotfiles/etc/. /etc/
sudo cp -r --preserve=mode,timestamps ~/dotfiles/boot/grub/themes/. /boot/grub/themes/
sudo grub-mkconfig -o /boot/grub/grub.cfg   # rebuild the boot menu so it uses the theme
sudo systemctl disable getty@tty2.service   # ly takes over the second text console
sudo systemctl enable ly@tty2.service NetworkManager.service bluetooth.service fstrim.timer reflector.timer
sudo systemctl start reflector.service   # pick the fastest download servers now (takes about 30 seconds)
```

The copies keep their permissions and dates but **not** their owner, so they end up owned by root like the rest of `/etc` and `/boot`. (`cp -a` would copy the owner too, and since the repo's files belong to your user account, that would let your normal account edit system files like `pam.d/ly` without sudo.)

A `grub` package update replaces `10_linux` and `30_uefi-firmware` with fresh copies. `09_wintux_menu` copes with that by itself (it re-tags "Advanced options" and switches `10_linux` off again every time the menu is rebuilt), but the UEFI settings entry loses its picture until the `--class efi` edit is redone.

### 5. Reboot

Needed for the login screen (ly) and the fan-sensor driver, and to see the new boot menu. At the ly login screen pick **Hyprland** (the plain one, not "uwsm").

### 6. After the first login

- **Keyring:** the first time an app wants to save a password, create a keyring named **login** with the **same password as your user account**. That's what makes it unlock on login. (If you later change your login password with `passwd`, the keyring won't follow.)
- **Firefox colours:** open Firefox once and close it, so it makes its profile folder. Find that folder under "Root Directory" in `about:profiles`, then `cp -a ~/dotfiles/firefox/. <that folder>/` and start Firefox again.
- **Spotify theme:** open Spotify once and close it, then run `spicetify backup apply`.
- **Blue Yeti volume:** with WirePlumber doing the volume in software, set the Yeti's own hardware volume to full once and save it:
  ```sh
  amixer -c 0 sset Speaker 100%   # check the card number with: aplay -l
  sudo alsactl store
  ```
- **Fonts:** run `fc-cache -f` so the hand-installed fonts are picked up, then set the GTK interface font (it's stored in a settings database, not a file):
  ```sh
  gsettings set org.gnome.desktop.interface font-name 'Iosevka 11'
  gsettings set org.gnome.desktop.interface document-font-name 'Iosevka 11'
  gsettings set org.gnome.desktop.interface monospace-font-name 'Iosevka 11'
  ```
- **Neovim plugins:** install vim-plug (the plugin manager), then let it fetch the plugins and add coc's language extensions:
  ```sh
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  nvim +PlugInstall +qa
  nvim +'CocInstall -sync coc-clangd coc-pyright coc-snippets' +qa
  ```
  Keep coc.nvim up to date (`:PlugUpdate coc.nvim`): old versions leave their pop-up boxes stuck on screen with newer Neovim.
- **Claude Code:** sign in with `claude`, then reinstall the claude-hud status line plugin (`/plugin`).
- Restart pieces after edits: `pkill dunst` (it restarts itself on the next notification), Super+Shift+R for the bar.

---

## Not included (on purpose)

Passwords, tokens and login data (`~/.claude.json`, keyrings, browser profiles apart from the three Firefox style files), app caches, the Spicetify backup of Spotify's original files, and the unused rofi theme pack.
