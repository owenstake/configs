
# [Powershell test for noninteractive mode - Stack Overflow](https://stackoverflow.com/questions/9738535/powershell-test-for-noninteractive-mode )
function IsInteractive {
    # not including `-NonInteractive` since it apparently does nothing
    # "Does not present an interactive prompt to the user" - no, it does present!
    $non_interactive = '-command', '-c', '-encodedcommand', '-e', '-ec', '-file', '-f', '-noexit'
    $interactive = , '-noexit'

    If ([Environment]::GetCommandLineArgs() | Where-Object -FilterScript {$PSItem -in $interactive}) {
        return $true
    }
    # alternatively `$non_interactive [-contains|-eq] $PSItem`
    -not ([Environment]::GetCommandLineArgs() | Where-Object -FilterScript {$PSItem -in $non_interactive})
}


If (!(IsInteractive)) {
    exit
}

$WinVersion = (Get-WmiObject Win32_OperatingSystem).BuildNumber

# basic setting
set-PSReadLineOption -EditMode Emacs

Function fmt_info {
	Write-Host $args -BackgroundColor DarkCyan
}

Function fmt_error {
	Write-Host $args -BackgroundColor DarkRed
}

Function Test-CommandExists($cmd) {
    If (Get-Command $cmd -ErrorAction SilentlyContinue) {
        return $true
    } else {
        return $false
    }

	# $oldPreference = $ErrorActionPreference
	# $ErrorActionPreference = 'stop'
	# try {if(Get-Command $command){RETURN $true}}
	# Catch {fmt_error "$command does not exist"; RETURN $false}
	# Finally {$ErrorActionPreference=$oldPreference}
}

Function Test-AppExistsInScoop($appName) {
    $scoopInfo = scoop export | ConvertFrom-Json
    If ($scoopInfo.apps | where-object -FilterScript {$PSitem -match "$appName"}) {
        return $true
    } else {
        return $false
    }
}

Function exp($pathName=".") {
    If ( !(Test-Path $pathName )) {
        throw [System.IO.FileNotFoundException] "$pathName not found."
    }
    return explorer.exe $pathName
}

Function yww() {
    # powershell -File 'D:\.local\win10\psh\file2clip.ps1' "$args"
    return powershell -Command "D:\.local\win10\psh\file2clip.ps1 $args"
}

Function pww() {
    return powershell -Command "D:\.local\win10\psh\clip2file.ps1 $args"
}

# zlua
If ( (Test-CommandExists lua) -and (Test-Path $env:scoop\apps\z.lua\current\z.lua) ) {
    Invoke-Expression (& { (lua $env:scoop\apps\z.lua\current\z.lua --init powershell) -join "`n" })
}

# psfzf
If ( (Test-CommandExists fzf) -and (Test-AppExistsInScoop "psfzf") ) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    If ( $WinVersion -lt 14931) {
        $env:FZF_CTRL_T_OPTS='--reverse'
    } else {
        $env:FZF_CTRL_T_OPTS="
            --prompt 'All> '
            --border
            --reverse
            --height 60%
            --preview 'bat {}'
            --header 'CTRL-D: Directories / CTRL-F: Files / CTRL-T: Zlua'
            --bind 'ctrl-d:change-prompt(Directories> )+reload(fd . $pwd --type directory)'
            --bind 'ctrl-f:change-prompt(Files> )+reload(fd . $pwd --type file )'
            "
    }
    $env:FZF_CTRL_R_OPTS='--reverse --height 25'
}
# Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
# $env:FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

If ( $WinVersion -lt 14931) {
	Set-alias vi  "${env:scoop}\shims\gvim.exe"
	Set-alias vim "${env:scoop}\shims\gvim.exe"
}

Function RealPath() {
    (Get-Item $args[0]).FullName
}

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "${env:ChocolateyInstall}\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

