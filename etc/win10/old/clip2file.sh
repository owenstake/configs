#!/bin/bash
# source powershell_env.sh

DesDirPath=$(wslpath -wa ${1:-.})

if [[ -z $2 ]]; then
    FILENAME="screenshot_"$(date +%Y-%m-%d-%H-%M-%S)".png"
else
    FILENAME=$2
fi

realpath=$(realpath $FILENAME)
filename=$(basename "$realpath")
dirname=$(dirname "$realpath")

WINFILENAME=$(wslpath -wa $dirname)"\\""$filename"

powershell.exe -File 'D:\.local\win10\clip2file.ps1' "$DesDirPath" "$WINFILENAME"  # etc/win10/clip2file.ps1
# $POWERSHELL_PATH -File 'D:\.local\win10\clip2file.ps1' "$DesDirPath" "$WINFILENAME"  # etc/win10/clip2file.ps1
