
$WorkDir='D:\.local\win10\'

function ExecFile($file) {
    $absPath=$WorkDir+$file
    explorer.exe $absPath
}

ExecFile 'ahk\keyremap.ahk'
ExecFile 'ahk\easy-marker\easy-marker.ahk'

