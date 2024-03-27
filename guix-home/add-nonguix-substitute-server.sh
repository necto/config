#!/bin/bash
# part of after-reboot.sh
set -xeuo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Add nonguix substitute server to avoid lengthy build of firefox
NONGUIX_SUBSTITUTE_URL="https://substitutes.nonguix.org"
GUIX_SUBSTITUTE_URL="https://ci.guix.gnu.org https://bordeaux.guix.gnu.org"
KEY_FILE="$SCRIPT_DIR/nonguix-signing-key.pub"
SERVICE_FILE="/lib/systemd/system/guix-daemon.service"

sudo sed -i "s@ExecStart=/usr/bin/guix-daemon@& --substitute-urls='$GUIX_SUBSTITUTE_URL $NONGUIX_SUBSTITUTE_URL'@" \
    "$SERVICE_FILE"
sudo systemctl daemon-reload
sudo systemctl restart guix-daemon.service
sudo guix archive --authorize < "$KEY_FILE"
