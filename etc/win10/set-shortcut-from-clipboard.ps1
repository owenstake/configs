# ref
# https://stackoverflow.com/questions/9701840/how-to-create-a-shortcut-using-powershell

param ( [string]$DesDirPath )

###########################################################
# copy file from clipboard to DesDir for win10 explorer
###########################################################

Add-Type -AssemblyName System.Windows.Forms
$fileDropList = new-object System.Collections.Specialized.StringCollection;

if (-not [System.Windows.Forms.Clipboard]::ContainsFileDropList()) {
    "Psh: No appendable content was found."
    return
} else {
    $fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList()
}

"Psh: Psh make SHORTCUT from clipboard $($fileDropList.count) Items to DesDir " 
"Psh: Destination Directory: "
"Psh:     " + (Get-Item -Path $DesDirPath).FullName
"Psh: Items: " 

$WshShell = New-Object -comObject WScript.Shell
foreach ($file in $fileDropList) {
    $DesFileLnk = (Get-Item -Path $DesDirPath).FullName + '\' + (Get-Item -Path $file).Name + '.lnk'
    "Psh:     " + $file + "`t=>`t" + $DesFileLnk

    # destinion file link filename
    $Shortcut = $WshShell.CreateShortcut($DesFileLnk) 
    # source file
    $Shortcut.TargetPath = $file 
    $Shortcut.Save()
}


