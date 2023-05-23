# Conditional source lib script
If ($env:lf) {
    . $env:LOCALAPPDATA\lf\lib.ps1
}

# ========== Lib for Script and Terminal ===========================
Function exp($pathName=".") {
    $pathName = $pathName.Trim("`"")  #
    If ( !(Test-Path $pathName )) {
        throw [System.IO.FileNotFoundException] "$pathName not found."
    }
    return explorer.exe $pathName
}

Function DoClipboard() {
    powershell -noprofile -Command "D:\.local\win10\psh\clipboard.ps1" @args
}

Function yww() {
    return DoClipboard "set" @args
}

Function pww() {
    return DoClipboard "get" @args
}

Function pwm() {
    return DoClipboard "move" @args
}

Function pss() {
    return DoClipboard "show"
}

# [Powershell test for noninteractive mode - Stack Overflow](https://stackoverflow.com/questions/9738535/powershell-test-for-noninteractive-mode )
Function IsInteractive {
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

Function Test-CommandExists($cmd) {
    If (Get-Command $cmd -ErrorAction SilentlyContinue) {
        return $true
    } else {
        return $false
    }
}

# Function Get-FileMimeType($file) {
#     $mimeType = file --mime-type -b $file
#     return $mimeType
# }

# Function LF-OpenFile($file) {
#     $mimeType = Get-FileMimeType($file)
#     Switch -wildcard  ($mimeType) {
#         "text/*" { vim $file }
#         default  { exp $file }
#     }
# }

# for lf
Function lfZlua($pattern) {
    # init zlua first
    If ( (Test-CommandExists lua) -and (Test-Path $env:scoop\apps\z.lua\current\z.lua) ) {
        Invoke-Expression (& { (lua $env:scoop\apps\z.lua\current\z.lua --init powershell) -join "`n" })
    }

    If(!$pattern) {
        lf -remote "send $env:id echo ZLUA: No args"
        return
    }
    $match = z -e "$pattern"
    If ($match) {
        $pathName = $match -replace "\\","\\"
        lf -remote "send $env:id cd $pathName"
        lf -remote "send $env:id echo ZLUA: cd to $pathName"
    } else {
        lf -remote "send $env:id echo ZLUA: No match for $pattern"
    }
    # lf -remote "send $env:id set user_zlua"
}

Function rgf($pattern) {
    If (!$pattern) {
        $pattern = Read-Host "Search"
    }
    $RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
    $INITIAL_QUERY=$pattern
    $env:FZF_DEFAULT_COMMAND="$RG_PREFIX $INITIAL_QUERY"
    fzf --ansi `
        --disabled --query "$INITIAL_QUERY" `
        --bind "change:reload:$RG_PREFIX {q}" `
        --delimiter : `
        --preview 'bat --color=always {1} --highlight-line {2}' `
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' `
        --bind 'enter:execute(vim {1} +{2})'
}

# Env fzf
$env:FZF_CTRL_T_OPTS="
    --prompt 'All> '
    --border --reverse --ansi --height 60%
    --preview '(bat --color=always {} || tre {} --directories) 2> nul'
    --header 'CTRL-D: Directories / CTRL-F: Files / CTRL-O Open It / CTRL-Y: Copy Name'
    --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-o:execute-silent(powershell -c Invoke-Item {})'
    --bind 'ctrl-d:change-prompt(Directories> )+reload(fd --type directory)'
    --bind 'ctrl-f:change-prompt(Files> )+reload(fd --type file )'
    --bind 'ctrl-i:execute-silent(powershell -c yww set {})'
    --bind 'ctrl-y:execute-silent(powershell -c echo {} | clip)'
    "
$env:FZF_CTRL_R_OPTS="
    --header 'Press CTRL-Y to copy command into clipboard'
    --reverse --height 60%
    --preview 'echo {}' --preview-window up:3:hidden:wrap
    --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-y:execute-silent(powershell -c echo {} | clip)'
    "


# Alias
Set-Alias trash recycle-bin.exe
# ---- end of lf script config ----
# ========== End of Lib for script and terminal ===========================

$isInter = IsInteractive
If (!$isInter) {
    exit 2
}

# ==================================================================
# ========== Terminal Configure ====================================
# ==================================================================
$WinVersion = (Get-WmiObject Win32_OperatingSystem).BuildNumber
$scoopInfo = scoop export | ConvertFrom-Json

# zlua init
If ( (Test-CommandExists lua) -and (Test-Path $env:scoop\apps\z.lua\current\z.lua) ) {
    Invoke-Expression (& { (lua $env:scoop\apps\z.lua\current\z.lua --init powershell) -join "`n" })
    Function zb {z -b}
    Function zc($p) {z -c $p}
    Function zr {cd ~/Desktop }
    Function zd {cd ~/Downloads }
    # refine cd as linux bash
    del alias:cd -errorAction silentlyContinue
    Function cd($dir="~") {
        If ($dir -eq "-") {
            z -
        } else {
            Set-Location "$dir"
        }
    }
}

# Basic setting
set-PSReadLineOption -EditMode Emacs

Function fmt_info { Write-Host @args -BackgroundColor DarkCyan }
Function fmt_warn { Write-Host @args -ForegroundColor Yellow -BackgroundColor DarkGreen }
Function fmt_error { Write-Host @args -BackgroundColor DarkRed }

Function UpdateScoopInfoCache {
    $scoopInfo = scoop export | ConvertFrom-Json
}

Function Test-AppExistsInScoopByCache($appName) {
    If ($scoopInfo.apps | where-object -FilterScript {$PSitem -match "$appName"}) {
        return $true
    } else {
        return $false
    }
}

Function Test-AppExistsInScoop($appName) {
    $scoopInfo = scoop export | ConvertFrom-Json
    UpdateScoopInfoCache
    Test-AppExistsInScoopByCache $appName 
}

# Class ScoopApps {
#     ScoopApps() {
#         $this.scoopInfo = scoop export | ConvertFrom-Json
#     }
#     [void]update() {
#         $this.scoopInfo = scoop export | ConvertFrom-Json
#     }
#     [bool]Test-AppExists([string]$appName) {
#         If ($this.scoopInfo.apps | where-object -FilterScript {$PSitem -match "$appName"}) {
#             return $true
#         } else {
#             return $false
#         }
#     }
# }

Function RealPath() {
    (Get-Item @args).FullName
}

# basic alias
del alias:rp -Force
Set-Alias rp RealPath
Set-Alias wrp RealPath

# basic function
Function vic { vim ~\_vimrc }
Function psc { vim $profile }

## git function
Function ga  {git add @args}
Function gd  {git diff @args}
Function gst {git status}
Function gca {git commit -v -a @args}

## jobs function
Function bg() {Start-Process -NoNewWindow @args}

# del alias:rm -errorAction silentlyContinue
# Function rm { @args }

# ls.exe
If ( (Test-CommandExists fd) -and (Test-AppExistsInScoopByCache "fd") ) {
    del alias:ls -errorAction silentlyContinue
    Function ls  {fd --max-depth 1 --strip-cwd-prefix --color always @args}
    Function la  {ls --hidden @args}
    Function ll  {ls -l @args}
    Function lla {ls -l --hidden @args}

    # Function ls  {ls.exe --color @args | echo }
    # Function la  {ls -a @args}
    # Function ll  {ls -l @args}
    # Function lla {ls -l -a @args}

}

# psfzf
If ( (Test-CommandExists fzf) -and (Test-AppExistsInScoopByCache "psfzf") ) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSFzfOption -EnableAliasFuzzyGitStatus  # fgs
    Function gaf {
        git add $(fgs)
    }
    # $env:FZF_DEFAULT_COMMAND="fd"
    $env:FZF_CTRL_T_COMMAND="fd --color always"

    # dos => --preview '(bat --color=always {} || tre {} --directories) 2> nul'
    # psh => --preview '((bat --color=always {}) -or (tre {} --directories)) 2> $null'
    $env:FZF_CTRL_T_OPTS=$env:FZF_CTRL_T_OPTS  # defined above
    $env:FZF_CTRL_R_OPTS=$env:FZF_CTRL_R_OPTS  # defined above
}
# Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
# $env:FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# If ( $WinVersion -lt 14931) {
# 	Set-alias vi  "${env:scoop}\shims\gvim.exe"
# 	Set-alias vim "${env:scoop}\shims\gvim.exe"
# }

If (Test-AppExistsInScoopByCache "autohotkey") {
    exp D:\.local\win10\ahk\keyremap.ahk
}
If (Test-AppExistsInScoopByCache("pscolor")) {
    # $env:PSCOLORS_HIDE_DOTFILE=$true
    Import-Module PSColor
}

$env:PAGER  = "bat"
$env:EDITOR = "vim"
# $env:SHELL="powershell"

exit 0
# ========== End Terminal Configure ====================================
