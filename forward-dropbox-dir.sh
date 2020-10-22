ORIG_USER=necto
FWD_USER=arseniy
sudo apt install bindfs
sudo mkdir -p /home/$ORIG_USER/Dropbox
sudo chown -R $FWD_USER:$FWD_USER /home/$FWD_USER/Dropbox
sudo bindfs --map=$ORIG_USER/$FWD_USER /home/$ORIG_USER/Dropbox/ /home/$FWD_USER/Dropbox
