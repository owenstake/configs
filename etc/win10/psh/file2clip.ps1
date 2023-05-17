#################################################
# copy file to clipboard for win10 explorer
#################################################

# Param([Parameter(Mandatory = $True, Position = 1)][string] $filePath)
echo "$PSCommandPath"

Function SetFileDropList() {
    Add-Type -AssemblyName System.Windows.Forms
    $files = new-object System.Collections.Specialized.StringCollection

    # get files from args
    Foreach ($arg in $args)
    {
        Foreach ($pathName in $(Get-Item -Path $arg)) {  # path maybe wildcard like *png
            $files.Add($pathName)
        }
    }

    # add files to clipboard
    If (-not [System.Windows.Forms.Clipboard]::SetFileDropList($files)) {
        $count = $files.count
        "PSH: Copy $count items to clipboard"
        Foreach ($file in $files)
        {
            "PSH:     " + $file
        }
    } else {
        "PSH: Fail SetFileDropList"
    }
}

SetFileDropList($args)

