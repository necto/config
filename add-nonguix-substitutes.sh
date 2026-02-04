# Must be run with sudo privileges

# Add non-guix substitute server last, to prefer the oficial Guix substitute servers.

sed -i \
  's|^\(\s*ExecStart=.*guix-daemon\)|\1 --substitute-urls="https://ci.guix.gnu.org https://bordeaux.guix.gnu.org https://substitutes.nonguix.org"|' \
  /etc/systemd/system/guix-daemon.service

systemctl daemon-reload
systemctl restart guix-daemon.service

# Authorize the non-guix substitute server's public key
# https://substitutes.nonguix.org/signing-key.pub
guix archive --authorize <<'EOF'
(public-key
 (ecc
  (curve Ed25519)
  (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))
EOF


