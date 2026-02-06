#!/usr/bin/env sh
# Wait until foot server is ready, then apply darkman color schema (dark/light)
# This is necessary because foot server starts not knowing the schema (defaulting to light),
# and darkman sends a signal only when it switches between dark/light,
# so if foot server starts during the night, it won't get the dark schema until a manual toggle or the next day.

while true; do
    # run a dummy command ("pwd") in footclient to check if the server is ready
    footclient --no-wait pwd >/dev/null 2>&1
    status=$?

    if [ "$status" -eq 0 ]; then
        # Server is ready
        break
    fi

    # Server not ready yet (exit 220 or 230)
    sleep 0.1
done

# apply darkman theme
~/.local/share/darkman/foot.sh "$(darkman get)"
