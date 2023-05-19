
$OwenLocalDir= 'D:\.local\win10'

Function ExecFile($file) {
    $filePath = "$OwenLocalDir\$file"
    explorer.exe $filePath
}

ExecFile 'ahk\keyremap.ahk'
ExecFile 'ahk\easy-marker\easy-marker.ahk'

# StartUp Scoop Apps
$DirScoopAppsDir = "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps"
explorer $DirScoopAppsDir\QQ.lnk

