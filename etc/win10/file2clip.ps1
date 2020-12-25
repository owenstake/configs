# copy file to clipboard for win10 explorer

# Param([Parameter(Mandatory = $True, Position = 1)][string] $filePath)
Add-Type -AssemblyName System.Windows.Forms
$files = new-object System.Collections.Specialized.StringCollection

foreach ($var in $args)
{
    # FullName is need. Get-Item usage can refer to 
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-item?view=powershell-7.1
    $files.Add((Get-Item -Path $var).FullName)
}
"# psh copy files to clipboard......."
$files 
if (-not [System.Windows.Forms.Clipboard]::SetFileDropList($files)) {
    Write-Verbose "psh: Fail SetFileDropList"
}
