# dotfiles
This README will explain the process of setting up a new Arch Linux install.

### Step 1: Install Arch Linux
Follow the installation guide: https://wiki.archlinux.org/title/Installation_guide

**NOTE:** When installing packages with pacstrap, make sure to install base-devel, linux-headers, git, vim, and dkms in addition to those listed in the installation guide.
### Step 2: Create new user account
```
useradd -mg users -G wheel,power,storage -s /bin/bash <username>
```
Add a password for the new account
```
passwd <username>
```
Add sudo privileges to the new account
```
EDITOR=vim visudo
```
Logout
```
exit
```
Log back in with the new user account
### Step 3: Install yay
Make a new **src** directory
```
mkdir src
```
Enter the new directory
```
cd src
```
Clone the yay repository
```
git clone https://aur.archlinux.org/yay.git
```
Give sudo permissions for the new directory to the main user
```
sudo chown -R <user> ./yay
```
Enter the directory and install yay
```
cd yay
makepkg -si
```
### Step 4: Install xorg and xinit
Run the following command and accept all defaults
```
sudo pacman -S xorg xorg-xinit
```
### Step 5: Install ly
```
yay -S ly
```
Enable ly
```
sudo systemctl enable ly
```
### Step 6: Install bspwm
```
sudo pacman -S bspwm sxhkd
```
### Step 7: Edit xinitrc and Xresources
```
vim ~/.xinitrc
```
Add the following line to the file:
```
exec bspwm
```
Now for ~/.Xresources
```
vim .Xresources
```
Add the following line:
```
Xft.dpi: 192
```
### Step 8: Create the bspwm and sxhkd configuration files and install Alacritty
Copy the files from the repo into their correct locations. Then install Alacritty:
```
sudo pacman -S alacritty
```
### Step 9: Reboot into the window manager
### Step 10: Install graphics and network drivers (and make caps lock an escape key)
Create /etc/X11/xorg.conf.d/10-keyboard.conf
```
vim /etc/X11/xorg.conf.d/10-keyboard.conf
```
See the repo file for what to add
```
sudo pacman -S nvidia
```
Create /etc/X11/xorg.conf.d/20-nvidia.conf
```
sudo vim /etc/X11/xorg.conf.d/20-nvidia.conf
```
See repo file for what to add
Reboot.

### Step 11: Install rofi, rofi themes, nvim (and vim-plug), picom-ibhagwan-git, pywal (and therefore pip), imagemagick, feh, pulseaudio, firefox, spotify, nerd fonts, dolphin, polybar, starship, pipes.sh, tty-clock-git, htop, gotop, neofetch, and fet.sh

See the repo for their configuration files.

After installing dolphin, install qt5ct. See this link for more info: https://wiki.archlinux.org/title/qt#Configuration_of_Qt5_apps_under_environments_other_than_KDE_Plasma
```
yay -S qt5ct
```
Set the following environment variable in ~/.bashrc:
```
export QT_QPA_PLATFORMTHEME=qt5ct
```
Install the breeze icon themes:
```
sudo pacman -S breeze-icons
```
Run qt5ct
```
qt5ct
```
Go to Icon Theme, select breeze, click apply. After opening Dolphin, the file icons should now be present.
