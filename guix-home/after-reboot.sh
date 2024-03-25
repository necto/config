#!/bin/bash
# to be run after the reboot when all the guix symlinks are in place
# and guix-home packages installed, and environment is set up
set -xeuo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Refresh all channels, including nonguix that was added by guix-home
# --fallback will make guix build the missing package from source if substitute fails
guix pull --fallback

# Install the common packages from the manifest (e.g., firefox)
guix package -m "$SCRIPT_DIR/manifest.scm"

# Install doom
bash "$HOME/.config/doom/install.sh"
