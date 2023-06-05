###########################################################
# copy file from clipboard to DesDir for win10 explorer
###########################################################

Param([Parameter(Mandatory = $True, Position = 1)][string] $DesDirPath)
Add-Type -AssemblyName System.Windows.Forms
$fileDropList = new-object System.Collections.Specialized.StringCollection;

if (-not [System.Windows.Forms.Clipboard]::ContainsFileDropList()) {
     "Psh: No appendable content was found."
     return
} else {
    $fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList()
}

"Psh: Psh copy clipboard $($fileDropList.count) Items to DesDir " 
"Psh: Destination Directory: "
"    " + (Get-Item -Path $DesDirPath).FullName
"Psh: Items: " 

foreach ($file in $fileDropList) {
    "Psh:     " + $DesDirPath + '\' + (Get-Item -Path $file).Name
    Move-Item -Path $file -Destination (Get-Item -Path $DesDirPath).FullName
    # Get-ChildItem -Path $file -Recurse | Move-Item -Destination (Get-Item -Path $DesDirPath).FullName
}
