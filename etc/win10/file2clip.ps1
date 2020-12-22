
$col = new-object Collections.Specialized.StringCollection
# $targetpath = "$pwd" + "\" + $args[0]
$targetpath = (Get-Item -Path $args[0]).FullName
# $targetpath = $targetpath.TrimStart('Microsoft.PowerShell.Core\FileSystem::')
"copy to clipboard ~~ " + $targetpath
# $targetpath = $targetpath = "'" + $targetpath + "'"
# $targetpath
$col.Add($targetpath)

# $col.Add("\\wsl$\Ubuntu-20.04\home\z\try\configs\bootstrap.sh")

if ($col.Count) {
    Add-Type -AssemblyName System.Windows.Forms
    [Windows.Forms.Clipboard]::SetFileDropList($col)
}
