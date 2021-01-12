#################################################
# copy file to clipboard for win10 explorer
#################################################

# Param([Parameter(Mandatory = $True, Position = 1)][string] $filePath)
Add-Type -AssemblyName System.Windows.Forms
$files = new-object System.Collections.Specialized.StringCollection

# get files from clipboard
if ([System.Windows.Forms.Clipboard]::ContainsFileDropList()) {
    $fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList()

    foreach ($file in $fileDropList) {
        $count = $files.Add((Get-Item -Path $file).FullName)
    }
}

# get files from args
foreach ($var in $args)
{
    # FullName is need. Get-Item usage can refer to 
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-item?view=powershell-7.1
    $count = $files.Add((Get-Item -Path $var).FullName)
}

$count++

# add files to clipboard
if (-not [System.Windows.Forms.Clipboard]::SetFileDropList($files)) {
    "PSH: Copy $count items to clipboard"
    foreach ($var in $args)
    {
        "PSH:     " + (Get-Item -Path $var).FullName
    }
} else {
    "PSH: Fail SetFileDropList"
}
