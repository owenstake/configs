
$WorkDir= 'D:\.local\win10'

function ExecFile($file) {
    $filePath = $WorkDir + '\' + $file
    explorer.exe $filePath
}

ExecFile 'ahk\keyremap.ahk'
ExecFile 'ahk\easy-marker\easy-marker.ahk'

