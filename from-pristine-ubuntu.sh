
sudo ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime
DEBIAN_FRONTEND=noninteractive sudo apt update && sudo apt install -y git python emacs
sudo dpkg-reconfigure --frontend noninteractive tzdata
cd ~
mv .bashrc .bashrc.bkp
git clone https://github.com/necto/config
cd config
./install
git remote set-url origin gh:necto/config

# More useful packages
sudo apt install -y vim wget unzip net-tools iputils-ping xmonad xmobar trayer feh suckless-tools x11-xserver-utils arandr help2man alsa-utils

# Build the tool used to control the backlight brightness
cd ~/config/xmonad/light && make && sudo ./makeexec.sh

ssh-keygen
echo "Add this key to your github.com account: https://github.com/settings/keys"
echo "X------------------------X"
cat ~/.ssh/id_rsa.pub
echo "X------------------------X"

# Dev packages
sudo apt install -y cmake ninja-build clang-10 ccache gcc lld clangd

# Notifications from the terminal:
sudo apt install -y libnotify-bin notify-osd

#install syncthing
sudo curl -s -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
printf "Package: *\nPin: origin apt.syncthing.net\nPin-Priority: 990\n" | sudo tee /etc/apt/preferences.d/syncthing
sudo apt-get update
sudo apt install -y syncthing
systemctl --user enable syncthing.service
systemctl --user start syncthing.service

# Now go to the web interface localhost:8384 and setup the paired devices and shared folders

# TODO: configure firefox, gtk (font size, etc), xmonad-as-the-default, docker

# ln -s ~/.xmonad/bin/xsession ~/.xsession
# Logout, login from slim/lightdm/xdm/kdm/gdm

# remove the terminal title-bar (gnome-terminal-server window decoration):
# Open dconf-editor, navigate to /org/gnome/terminal/legacy/headerbar and change it to False
# from https://askubuntu.com/questions/1138272/removing-window-decorations-of-gnome-terminal-in-ubuntu-19-04

# Hide the menu-bar in the gnome terminal by default:
# gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false

