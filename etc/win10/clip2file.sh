#!/bin/bash
# source powershell_env.sh

DesDirPath=$(wslpath -wa ${1:-.})
$POWERSHELL_PATH -File 'D:\.local\win10\clip2file.ps1' "$DesDirPath"          # etc/win10/clip2file.ps1
