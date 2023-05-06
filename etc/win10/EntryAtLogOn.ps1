
$ConfigDir='D:\.local\win10\'

function ExecFile($file) {
    $absPath=$ConfigDir+$file
    explorer.exe $absPath
}

ExecFile 'keyremap.ahk'
ExecFile 'easy-marker\easy-marker.ahk'

