
# Get-ChileItem "$Env:OwenInstallDir/etc/rc*"
$startupDir = "D:\.local\etc\init.d"
If (!(Test-Path "$startupDir")) {
    "Start up Dir is non-exists. $startupDir"
    cmd /c pause
    exit -1
}

Get-ChileItem $startupDir | Foreach { explorer.exe $_}

# Foreach ($dir in $dirs) {
#     $files = Get-Item $dir -File
#     Foreach ($file in $files) {
#         explorer.exe $file
#     }
# }

