
Add-Type -AssemblyName System.Windows.Forms

if (-not [System.Windows.Forms.Clipboard]::ContainsFileDropList()) {
    Write-Verbose "No appendable content was found."
} else {
    [System.Collections.Generic.List[string]]$fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList()
}

foreach ($item in $fileDropList) {
 [console]::writeline($item)
 [console]::writeline("\n")
}
[console]::writeline("hello world")

# ($fileDropList).ForEach([console]::writeline)
