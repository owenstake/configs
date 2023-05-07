
$WorkDir='D:\.local\win10\'

function ExecFile($file) {
    $absPath=$WorkDir+$file
    explorer.exe $absPath
}

ExecFile 'keyremap.ahk'
ExecFile 'easy-marker\easy-marker.ahk'

