sudo apt install bindfs
sudo mkdir -p /home/arseniy/Dropbox
sudo chown -R arseniy:arseniy /home/arseniy/Dropbox
sudo bindfs --map=necto/arseniy /home/necto/Dropbox/ /home/arseniy/Dropbox
