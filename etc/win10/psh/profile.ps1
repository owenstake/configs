# ========== Lib for Script and Terminal ===========================
# Env
$env:WEIYUN = "D:\owen\weiyun"
# Function
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
    $files = DoClipboard "show"
    If ($files) {
        "PSH: $($files.count) items in clipboard"
        Foreach($file in $files) {
            "PSH:     $file"
        }
    } else {
        "PSH: Nothing in clipboard"
    }
    return
}

Function ahk2exe($ahkFile, $exeFile) {
    If(!$ahkFile) {
        echo "ERR: No args"
        return
    }
    if (!$exeFile) {
        $file = Get-Item $ahkFile
        $exeFile = $file.DirectoryName + '\' + $file.Basename + '.exe'
    }
    ahk2exe.exe /silent /in $ahkFile /out $exeFile /base "$env:scoop\apps\autohotkey1.1\current\Compiler\Unicode 64-bit.bin"
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

Function trash() {
    # safety check
    Foreach ($file in $args) {
        If (!(Test-Path $file)) {
            echo "No exists file => $file"
            return $false
        }
    }
    
    echo "PSH: Remove $($args.count) items"
    Foreach ($file in $args) {
        echo "PSH:     Remove $file"
    }
    recycle-bin.exe @args
}

# Scoop - maybe used in autohotkey ahk
Function GetScoopAppShortcut($app) {
	If ($s = (scoop cat $app | ConvertFrom-json).shortcuts) {
		return "$(scoop prefix $app)\$($s[0][0])"
	}
    return
}

Function ScoopAppStart($app) {
    # Invoke-Item "$env:scoopUiApps\$app.lnk"
	If ($s = GetScoopAppShortcut $app) {
		exp "$s"
	} else {
		echo "No shortcut for $app to start"
	}
}

# Match Order - app.exe
# 1. app.exe in $env:path
# 2. app.lnk in dir *Programs
# 3. app.exe the app.lnk in dir *Programs
# *program dir
# 1. C:\ProgramData\Microsoft\Windows\Start Menu\Programs
# 2. C:\Users\owen\AppData\Roaming\Microsoft\Windows\Start Menu\Programs
Function GetAppExe($appExe) {
    # exe path
    $appName = $appExe -Replace "\.exe",""
    $lnks    = Get-ChildItem -R *.lnk -Path `
                "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\",`
                "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs" 

    $sh = New-Object -ComObject WScript.Shell
    Foreach ($l in $lnks) {
        If ($l.Basename -eq $appName) {
            return  $l.FullName
        }
        $tp = $sh.CreateShortcut($l.FullName).TargetPath
        # If (($tp) -and (Test-Path $tp)) {
        If (($tp) -and (Test-Path $tp -PathType leaf)) {
            # echo "$($l.FullName)"
            # echo "$tp"
            # echo $(Get-Item $tp).Name 
            # echo $appName
            if ($(Get-Item $tp).Basename -eq $appName) {
                # echo $tp
                return  $tp
            }
        }
    }
    write-error "no match in GetAppExe in powershell. app name is $appExe."
    return
}

# Recommand win-key search first
Function sapp($app) {
    ScoopAppStart $app
}

# Ripgrep
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

If (Test-Path ~\.zlua) {
    Function zff() {
        return cat ~\.zlua | Sort-Object { [double]($_ -split '\|')[1] } -Descending | Foreach { ($_ -split '\|')[0] }
    }
    Function zf($pattern) {
        If ($pattern) {
            cd (zff | & fzf --reverse --height 50% --query $pattern)
        } else {
            cd (zff | & fzf --reverse --height 50%)
        }
    }
}

# Env fzf
# --bind 'ctrl-o:execute-silent(powershell -c Invoke-Item {})'
# --preview '(bat --color=always {} || tre {} --directories) 2> nul'
# Fzf is use cmd.exe as default shell if $env:shell or %SHELL% is not set.
$env:FZF_CTRL_T_OPTS="
    --prompt 'All> '
    --border --reverse --ansi --height 60%
    --preview '(bat --color=always {} || cd {} && fd . --max-depth 1 --strip-cwd-prefix --color always) 2> nul'
    --header 'CTRL-D: Directories / CTRL-F: Files / CTRL-T: Zlua / CTRL-S: Scoop UI Apps
CTRL-O: Open It / CTRL-Y: Copy it / CTRL-I: Copy name'
    --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-d:change-prompt(Directories> )+reload(fd --type directory)'
    --bind 'ctrl-f:change-prompt(Files> )+reload(fd --type file )'
    --bind 'ctrl-t:change-prompt(Zlua> )+reload(powershell -c zff)'
    --bind 'ctrl-s:change-prompt(Scoop Ui App> )+reload(ls `"%scoopUiApps%\`")'
    --bind 'ctrl-o:execute-silent(start {})'
    --bind 'ctrl-i:execute-silent(powershell -c echo {} | clip)'
    --bind 'ctrl-y:execute-silent(powershell -c yww set {})'
    "

# ---- end of lf script config ----
# ========== End of Lib for script and terminal ===========================

# Conditional source lib script
If ($env:lf) {    # For lf
    . $env:LOCALAPPDATA\lf\lib.ps1
}

# exit if we are in script.
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
    Function zw {cd $env:weiyun }

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
    # Function ls  {fd --max-depth 1 --strip-cwd-prefix --color always @args}
    # Function la  {ls --hidden @args}
    # Function ll  {ls -l @args}
    # Function lla {ls -l --hidden @args}

    Function ls  {ls.exe -h --color @args | echo }
    Function la  {ls -a @args}
    Function ll  {ls -l @args}
    Function lla {ls -l -a @args}

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

# If (Test-Path "D:\.local\bin\keyremap.ahk") {
exp D:\.local\win10\ahk\keyremap.ahk
#     # D:\.local\bin\keyremap.exe
# }

If (Test-AppExistsInScoopByCache("pscolor")) {
    # $env:PSCOLORS_HIDE_DOTFILE=$true
    Import-Module PSColor   # format Get-childitem/ls result
}

$env:PAGER  = "bat"
$env:EDITOR = "vim"
# $env:SHELL="powershell"

exit 0
# ========== End Terminal Configure ====================================
