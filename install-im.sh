#sudo apt-get install libappindicator-dev # fix the missing tray icon (doesn't work)
sudo snap install skype slack --classic
sudo snap install telegram-desktop

# Zoom
wget -O ~/Downloads/zoom.deb https://zoom.us/client/latest/zoom_amd64.deb
cd ~/Downloads
sudo apt --fix-broken install ./zoom.deb
