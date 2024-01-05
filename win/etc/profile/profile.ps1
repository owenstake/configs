
. $pscommandpath/../lib-script.ps1

# Conditional source lib script
If ($env:lf) { . $env:LOCALAPPDATA\lf\lib.ps1 }
If (!(IsInteractive)) { exit 2 }    # Exit if we are in script.

# ==================================================================
# ========== Terminal Configure ====================================
# ==================================================================
. $pscommandpath/../lib-cli.ps1

If (($Env:OwenInstallDir) -and
    ($file = (Get-ChildItem $Env:OwenInstallDir -Recurse "keyremap.ahk").FullName)) {
        exp $file
}

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

# $env:PAGER  = "bat"
$env:EDITOR = "vim"
# $env:SHELL="powershell"

exit 0
# ========== End Terminal Configure ====================================
