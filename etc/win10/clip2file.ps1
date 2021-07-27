###########################################################
# Copy file from clipboard to $DesDir for win10 explorer
###########################################################

Param(
    [Parameter(Mandatory = $True, Position = 1)][string] $DesDirPath, 
    [Parameter(Position = 2)][string] $IMGNAME
)

Add-Type -AssemblyName System.Windows.Forms
$fileDropList = new-object System.Collections.Specialized.StringCollection;

if (-not [System.Windows.Forms.Clipboard]::ContainsFileDropList()) {
    $clipboard = [System.Windows.Forms.Clipboard]::GetDataObject()
    if ($clipboard.ContainsImage()) {
        $img = get-clipboard -format image
        $img.save($IMGNAME)
        "clipboard content saved as $IMGNAME"
        return
    } else {
        "clipboard does not contains image data"
    }

    "Psh: No appendable content was found."
    return
} else {
    $fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList()
}

"Psh: Psh copy clipboard $($fileDropList.count) Items to DesDir " 
"Psh: Destination Directory: "
"Psh:     " + (Get-Item -Path $DesDirPath).FullName
"Psh: Items: " 

foreach ($file in $fileDropList) {
    "Psh:     " + $file + "`t=>`t" + $DesDirPath + '\' + (Get-Item -Path $file).Name
    Copy-Item -Path $file -Destination (Get-Item -Path $DesDirPath).FullName -Recurse
}
