#!/bin/bash

# Solarized color scheme for Fuzzel dark and light
case "$1" in
    light)
        # Solarized Light
        BG="fdf6e3ff"       # base3
        TEXT="657b83ff"     # base00
        MATCH="cb4b16ff"    # orange
        SELECTION="eee8d5ff" # base2
        SEL_TEXT="586e75ff"  # base01
        BORDER="93a1a1ff"    # base1
        ;;
    dark)
        # Solarized Dark
        BG="002b36ff"       # base03
        TEXT="839496ff"     # base0
        MATCH="cb4b16ff"    # orange
        SELECTION="073642ff" # base02
        SEL_TEXT="93a1a1ff"  # base1
        BORDER="586e75ff"    # base01
        ;;
esac

cat <<EOF > ~/.cache/fuzzel-colors.ini
[colors]
background=$BG
text=$TEXT
match=$MATCH
selection=$SELECTION
selection-text=$SEL_TEXT
border=$BORDER
EOF
