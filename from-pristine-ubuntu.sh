
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

# TODO: configure firefox, gtk (font size, etc), xmonad-as-the-default, docker

# ln -s ~/.xmonad/bin/xsession ~/.xsession
# Logout, login from slim/lightdm/xdm/kdm/gdm

# remove the terminal title-bar (gnome-terminal-server window decoration):
# Open dconf-editor, navigate to /org/gnome/terminal/legacy/headerbar and change it to False
# from https://askubuntu.com/questions/1138272/removing-window-decorations-of-gnome-terminal-in-ubuntu-19-04
