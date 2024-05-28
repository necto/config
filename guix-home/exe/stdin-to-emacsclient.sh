#!/bin/sh
# Write stdin to a temporary file and open it in emacsclient.
# foot pipe-command-output will send the output via stdin
f=$(mktemp)
cat - > $f
# Originally was footclient instead of foot, but I don't consistently run foot --server,
# so client fails to start
foot emacsclient -nw $f
rm $f
