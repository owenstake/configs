# copy file to clipboard for win10 explorer

Param([Parameter(Mandatory = $True, Position = 1)][string] $filePath)
Add-Type -AssemblyName System.Windows.Forms
$files = new-object System.Collections.Specialized.StringCollection

# FullName is need. Get-Item usage can refer to 
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-item?view=powershell-7.1
$files.Add((Get-Item -Path $filePath).FullName)
[System.Windows.Forms.Clipboard]::SetFileDropList($files)
