#################################################
# copy file to clipboard for win10 explorer
#################################################

# Param([Parameter(Mandatory = $True, Position = 1)][string] $filePath)
Function SetFileDropList() {
    Add-Type -AssemblyName System.Windows.Forms
    $files = new-object System.Collections.Specialized.StringCollection

    # get files from args
    Foreach ($arg in $args)
    {
        # FullName is need. Get-Item usage can refer to 
        # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-item?view=powershell-7.1
        Foreach ($pathName in $(Get-Item -Path $arg)) {  # path maybe wildcard like *png
            $count = $files.Add($pathName)
        }
    }
    $count++

    # add files to clipboard
    If (-not [System.Windows.Forms.Clipboard]::SetFileDropList($files)) {
        "PSH: Copy $count items to clipboard"
        Foreach ($file in $files)
        {
            "PSH:     " + $file
        }
    } else {
        "PSH: Fail SetFileDropList"
    }
}

Function AppendFileDropList() {
    Add-Type -AssemblyName System.Windows.Forms
    $files = new-object System.Collections.Specialized.StringCollection

    # get files from clipboard
    if ([System.Windows.Forms.Clipboard]::ContainsFileDropList()) {
        $fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList()

        foreach ($file in $fileDropList) {
            $count = $files.Add((Get-Item -Path $file).FullName)
        }
    }
    SetFileDropList($file, $args)
}

Function ShowFileDropList() {
    Add-Type -AssemblyName System.Windows.Forms
    $files = new-object System.Collections.Specialized.StringCollection

    # get files from clipboard
    if ([System.Windows.Forms.Clipboard]::ContainsFileDropList()) {
        $fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList()

        foreach ($file in $fileDropList) {
            $count = $files.Add((Get-Item -Path $file).FullName)
        }
    }
    # Write-Host $files
    return $files
}


