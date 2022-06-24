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
