#!/usr/bin/env bash

# Rely on foot server to keep the current darkman theme (light/dark),
# so that all the newly spawned terminals (footclients) automatically use the right one.
# Otherwise, new-spun terminals whould default to light theme even during the night.
# 
# A robust way to spawn a terminal:
# - Normally foot server should be already running, so just run footclient
# - if that fails with "server not found" or "connection error", then:
#  1. Start foot server in the background
#  2. Wait until foot server is ready to accept clients
#  3. Apply the current darkman theme to foot (if darkman is available
#  4. Finally, run footclient again (replacing the current script process)

# Function to handle server startup and theme application
start_server_and_apply_theme() {
    # 1. Start the foot server in a detached process
    foot --server >/dev/null 2>&1 &
    
    # 2. Wait until foot server is ready
    while true; do
        if footclient --no-wait pwd >/dev/null 2>&1; then
            break
        fi
        sleep 0.1
    done

    # 3. Integrated theme logic: apply current darkman schema
    if command -v darkman >/dev/null 2>&1; then
        ~/.local/share/darkman/foot.sh "$(darkman get)" &
    fi
}

# Try to run the client
footclient "$@"
EXIT_CODE=$?

# If exit code is 220 (server not found) or 230 (connection error)
if [ $EXIT_CODE -eq 220 ] || [ $EXIT_CODE -eq 230 ]; then
    echo "Foot server not running. Initializing..."
    
    start_server_and_apply_theme
    
    # Final execution: replaces the current script process with the client
    exec footclient "$@"
fi

# If it was a different error or success, exit with the original code
exit $EXIT_CODE
