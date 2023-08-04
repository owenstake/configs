
# ========== Lib for Script and Terminal ===========================
# Env

# Function
Function exp($pathName=".") {
    $pathName = $pathName.Trim("`"")  #
    If ( !(Test-Path $pathName )) {
        throw [System.IO.FileNotFoundException] "$pathName not found."
    }
    return explorer.exe $pathName
}

Function DoClipboard() {
    $file = (Get-ChildItem $Env:OwenInstallDir -Recurse "clipboard.ps1").FullName
    powershell -noprofile -Command $file @args
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

Function Trash() {   # used in lfrc
    # safety check
    Foreach ($file in $args) {
        If (!(Test-Path $file)) {
            echo "No exists file => $file"
            return $false
        }
    }
    
    echo "PSH: Remove $($args.count) items to Recycle-bin"
    Foreach ($file in $args) {
        echo "PSH:     Remove $file"
    }
    recycle-bin.exe @args
}

Function Extract($filename) {
    echo "$filename"
    If (!($file = Get-Item $filename)) {
        return -1
    }
    $basename = $file.basename
    & 7z x $filename -o"${basename}"
}

# Match Order - app.exe
# 1. app.exe in $env:path
# 2. app.lnk in dir *Programs
# 3. app.exe the app.lnk in dir *Programs
# *program dir
# 1. C:\ProgramData\Microsoft\Windows\Start Menu\Programs
# 2. C:\Users\owen\AppData\Roaming\Microsoft\Windows\Start Menu\Programs
Function Get-AppExe($appExe) {
    # exe path
    $appName = $appExe -Replace "\.exe",""
    $lnks    = Get-ChildItem -R *.lnk -Path `
                "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\",`
                "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs" 

    $sh = New-Object -ComObject WScript.Shell
    Foreach ($l in $lnks) {
        $tp = $sh.CreateShortcut($l.FullName).TargetPath
        If ($l.Basename -eq $appName) {
            # return  $l.FullName
            return  $tp   # return .exe path not .lnk
        }
        If (($tp) -and (Test-Path $tp -PathType leaf)) {
            if ($(Get-Item $tp).Basename -eq $appName) {
                # echo $tp
                return  $tp
            }
        }
    }
    Write-Error "no match in Get-AppExe in powershell. app name is $appExe."
    return
}

Function Start-App($app) {
    Explorer.exe $(Get-AppExe $app)
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

