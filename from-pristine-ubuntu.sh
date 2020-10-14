
ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime
DEBIAN_FRONTEND=noninteractive apt update && apt install -y git python emacs
dpkg-reconfigure --frontend noninteractive tzdata
cd ~
mv .bashrc .bashrc.bkp
git clone https://github.com/necto/config
cd config
./install

# More useful packages
apt install vim xmonad wget unzip

ssh-keygen
echo "Add this key to your github.com account: https://github.com/settings/keys"
echo "X------------------------X"
cat ~/.ssh/id_rsa.pub
echo "X------------------------X"

# Dev packages
apt install -y cmake ninja-build clang-10 ccache gcc lld clangd

# TODO: configure firefox, gtk (font size, etc), xmonad-as-the-default, docker

# ln -s ~/.xmonad/bin/xsession ~/.xsession
# Logout, login from slim/lightdm/xdm/kdm/gdm
