
$WinVersion = (Get-WmiObject Win32_OperatingSystem).BuildNumber

# basic setting
set-PSReadLineOption -EditMode Emacs

# zlua
Invoke-Expression (& { (lua $env:scoop\apps\z.lua\current\z.lua --init powershell) -join "`n" })

# fzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
$env:FZF_CTRL_T_OPTS=' --reverse'
$env:FZF_CTRL_R_OPTS=' --reverse --height 20'
# Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
# $env:FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

If ( $WinVersion -lt 14931) {
	Set-alias vi  "$env:scoop\shims\gvim.exe"
	Set-alias vim "$env:scoop\shims\gvim.exe"
}

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

