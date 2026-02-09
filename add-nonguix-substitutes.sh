# Must be run with sudo privileges

# 1. Dynamically find the current location of the service file
SERVICE_PATH=$(systemctl show -p FragmentPath guix-daemon.service | cut -d= -f2)

if [ -z "$SERVICE_PATH" ]; then
    echo "Error: Could not locate guix-daemon.service"
    exit 1
fi

echo "Found service file at: $SERVICE_PATH"

# 2. Check if the file is in a vendor directory (/lib or /usr/lib)
# If so, copy it to /etc/systemd/system/ so we edit a local override instead.
if [[ "$SERVICE_PATH" == /usr/lib/* ]] || [[ "$SERVICE_PATH" == /lib/* ]]; then
    echo "Copying service file to /etc/systemd/system/ to avoid editing vendor files..."
    cp "$SERVICE_PATH" /etc/systemd/system/guix-daemon.service
    SERVICE_PATH="/etc/systemd/system/guix-daemon.service"
fi

# 3. Apply the edit to the (potentially new) file path
# Note: Added a check to ensure we don't add the URL twice if run repeatedly
if ! grep -q "substitutes.nonguix.org" "$SERVICE_PATH"; then
    sed -i \
      's|^\(\s*ExecStart=.*guix-daemon\)|\1 --substitute-urls="https://ci.guix.gnu.org https://bordeaux.guix.gnu.org https://substitutes.nonguix.org"|' \
      "$SERVICE_PATH"
    echo "Substitute URLs added."
else
    echo "Substitute URLs already present. Skipping sed."
fi

# 4. Reload and Restart
systemctl daemon-reload
systemctl restart guix-daemon.service

# 5. Authorize the key
guix archive --authorize <<'EOF'
(public-key
 (ecc
  (curve Ed25519)
  (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))
EOF
