#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <key>"
    echo "  key: h/j/k/l"
    exit -1
fi
scriptName="$0"
key=$1
declare -A keymap

keymap[h]="Left"
keymap[j]="Down"
keymap[k]="Up"
keymap[l]="Right"

xvkbd -xsendevent -text "\[${keymap[$key]}]"



