
Set-Location $pscommandpath/..

# . $pscommandpath/../lib.ps1
. ./lib.ps1

if ($file = Get-ChildItem . -Recurse "lib-script.ps1") {
    . $file.Fullname  # contain Get-AppExe
}

### Global var ########
Function EnvSetup() {
    if ((Get-Volume).DriveLetter -contains "d"){
        SetEnvVar "OwenInstallDir" "D:\.dotfiles"
        SetEnvVar "WEIYUN"         "D:\owen\weiyun"
    } else {
        SetEnvVar "OwenInstallDir" "~/.dotfiles"
        SetEnvVar "WEIYUN"         "~/owen/weiyun"
    }
    SetEnvVar "LF_CONFIG_HOME" "$Env:OwenInstallDir\etc\lf"
}

Function AddHookToConfigFile($filePath, $msg, $commentMark=@("#",""), 
                                $encoding="unicode", $insertLineNum="-1") {
    $leftCommentMark  = $commentMark[0]
    $rightCommentMark = $commentMark[1]
    $markLine   = "$leftCommentMark owen configed$rightCommentMark"
    $sourceLine = "${msg} ${markLine}"
    New-Item-IfNoExists $filePath
    $text = Get-Content $filePath
    if (!($text | Select-String -Pattern "$markLine" -SimpleMatch)) {
        fmt_info "AddHook: Add to owen $filePath"
        # $sourceLine | Out-File -Append -Encoding $encoding $filePath  # _vimrc will be utf8 format
        Switch ($insertLineNum) {
        -1     { $newText = $text + @($sourceLine) }  # last  line
        0  { $newText = @($sourceLine) + $text } # first line 
        default   { fmt_error "AddHook: Unknow insertLineNum $insertLineNum"; return}
        }
    } else {
        fmt_info "AddHook: Update owen config in $filePath"
        $newText = $text | Foreach { 
            If ($_.contains("$markLine")) {
                $_ = $sourceLine
            };
            $_
        }
    }
    $newText | Out-File -Encoding $encoding $filePath
}

Function DeployConfigDir($srcDir, $dstDir) {
    "Deploy $srcDir to $dstDir"
    Mkdir-P $dstDir
	cp -r -Force $srcDIr/* "$dstDir"
}

Function AddStartupTask($filePath) {
    If (!(Get-Item $filePath -errorAction silentlyContinue)) {
        fmt_warn "AddStartupTask() fail, $filePath do not exists"
        return
    }
    "Add Startup Task $filePath"
    $initd = "$Env:OwenInstallDir/etc/init.d"
    Mkdir-P $initd
    CreateShortCutToDir $filePath $initd
}

Function AddAppToStartupTask($app) {
    If (!(Test-CommandExists "$app")) {
        fmt_warn "AddAppStartupTask() fail, $app do not exists"
        return
    }
    return AddStartupTask "$(Get-AppExe $app)"
}

Function MakeAll() {
    # Make
    fmt_info "Compiling ahk/go/ps for bin."
    if ($file = Get-ChildItem -Recurse "previewer.go") {  # preview for lf
        fmt_info "Compile $file to bin/$($file.basename).exe"
        go build -o "bin/$($file.basename).exe" "$file"
    }
    if ($file = Get-ChildItem -Recurse "keyremap.ahk") {
        fmt_info "Compile $file to bin/$($file.basename).exe"
        ahk2exe "$file" "bin\$($file.basename).exe"   # must be backslash for ahk2exe
    }
    if ($file = Get-ChildItem -Recurse "easy-marker.ahk") {
        fmt_info "Compile $file to bin/$($file.basename).exe"
        ahk2exe "$file" "bin\$($file.basename).exe"   # must be backslash for ahk2exe
    }
    if ($file = Get-ChildItem -Recurse "xshell-proxy.ps1") {
        fmt_info "Compile $file to bin/$($file.basename).exe"
        ps2exe -inputFile "$file" -outputFile "bin/$($file.basename).exe"
    }
}

Function MakeClean() {
    Remove-Item bin -r -force
}

Function MakeUninstall() {
    Remove-Item $env:OwenInstallDir
}

Function MakeInstall() {
    # New-Item-IfNoExists  "$Env:OwenInstallDir"  "Directory"
    "--- Env setup ----"
    EnvSetup

    "--- Deploy Config File ----"
    DeployConfigDir  "../common/etc/vim"  "$Env:OwenInstallDir/etc/vim"
    # DeployConfigDir  "../common/etc/nvim" "$Env:LOCALAPPDATA/nvim"
    $luaFile ="../common/etc/init-in-one.lua" 
    if (Test-Path -pathtype Container $luaFile) {
        cp "$luaFile" "$Env:LOCALAPPDATA/nvim/init.lua"
    }
    # DeployConfigDir  "etc/lf"             "$Env:LF_CONFIG_HOME"
    DeployConfigDir  "etc/lf"             "$Env:LOCALAPPDATA/lf"
    DeployConfigDir  "etc/profile"        "$Env:OwenInstallDir/etc/profile"
    DeployConfigDir  "etc/common"         "$Env:OwenInstallDir/etc/common"
    If (Test-CommandExists typora.exe) {
        DeployConfigDir  "etc/typora/css"         "$Env:APPDATA/Typora/themes/owen"
    }

    "--- Write hook to vim and powrshell profile, because vim, profile can not be custom path"
    AddHookToConfigFile "$HOME\_vimrc"  "source $Env:OwenInstallDir/etc/vim/vimrc"  @('"','') "utf8"          # vimrc must be utf8 for parsing
    AddHookToConfigFile "$Profile"      ". $Env:OwenInstallDir/etc/profile/profile.ps1; If (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }"
    AddHookToConfigFile "$Env:APPDATA/Typora/themes/github.css" '@import "owen/owen.css";'  @("/*","*/")   "utf8" 0

    # # v2ray
    # $file = Get-ChildItem $env:OwenInstallDir -Recurse "pac.txt"
    # cp $file "D:\owen\scoop\apps\v2rayN\current\guiConfigs\pac.txt"

    "--- Crack typora ---"
    if ($file = Get-ChildItem -Recurse "winmm.dll") {
		if ((Test-CommandExists typora.exe) -and
            ($tyExe = $(Get-AppExe 'typora')) -and
            ($tyDir = $(Get-Item $tyExe).DirectoryName)) {
			cp $file $tyDir -errorAction silentlyContinue
		}
	}

    "--- Deploy bin files ---"
    DeployConfigDir "bin"  "$Env:OwenInstallDir/bin"

    "--- Deploy bin files ---"
    DeployConfigDir "scripts"  "$Env:OwenInstallDir/scripts"

    "--- Setup Start Task ----"
    # Add startup hook
    if ($file = Get-ChildItem -Recurse "owen-startup.cmd") {
        $DirStartUp = "$ENV:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
        cp $file $DirStartUp\ -Force   # add win10 startup hook. Real Startup script is EntryAtLogOn
    } else {
        "owen-startup.cmd is missed"
    }

    # Add startup task
    AddAppToStartupTask "qq"
    AddAppToStartupTask "proxifier"
    AddAppToStartupTask "V2rayN"
    if ($file = Get-ChildItem "$Env:OwenInstallDir" -Recurse "keyremap.ahk") {
        AddStartupTask $file.FullName
    }
}

Function Main($action) {
    Switch ($action) {
    ""          { MakeAll }
    "all"       { MakeAll }
    "clean"     { MakeClean }
    "install"   { MakeInstall }
    "uninstall" { MakeUninstall }
    default     {"Unknow action $action"}
    }
}

Main $script:args[0]

