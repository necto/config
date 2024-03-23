set -xeuo pipefail

sudo apt update 
sudo apt upgrade -y 
sudo snap refresh 
sudo apt-get install linux-oem-22.04d -y
