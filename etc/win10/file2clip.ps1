
Param([Parameter(Mandatory = $True, Position = 1)][string] $filePath)
Add-Type -AssemblyName System.Windows.Forms
$files = new-object System.Collections.Specialized.StringCollection
$files.Add((Get-Item -Path $filePath).FullName)
[System.Windows.Forms.Clipboard]::SetFileDropList($files)

# $col = new-object Collections.Specialized.StringCollection
# $targetpath = (Get-Item -Path $args[0]).FullName
# "copy to clipboard ~~ " + $targetpath
# $col.Add($targetpath)
# 
# if ($col.Count) {
#     Add-Type -AssemblyName System.Windows.Forms
#     [Windows.Forms.Clipboard]::SetFileDropList($col)
# }
