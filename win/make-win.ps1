
Set-Location $pscommandpath/..

# . $pscommandpath/../lib.ps1
. ./lib.ps1

if ($file = Get-ChildItem . -Recurse "lib-script.ps1") {
    . $file.Fullname  # contain Get-AppExe
}

Function EnvSetup() {
    SetEnvVar "OwenInstallDir" "D:\.dotfiles"
    SetEnvVar "LF_CONFIG_HOME" "$Env:OwenInstallDir\etc\lf"
    SetEnvVar "WEIYUN"         "D:\owen\weiyun"
}

Function AddHookToConfigFile($filePath, $msg, $leftCommentMark="#", 
                $rightCommentMark="", $encoding="unicode", $action="add") {
    $markLine   = "$leftCommentMark owen configed$rightCommentMark"
    $sourceLine = "${msg} ${markLine}"
    New-Item-IfNoExists $filePath
    $text = Get-Content $filePath
    if (!($text | Select-String -Pattern "$markLine" -SimpleMatch)) {
        fmt_info "AddHook: Add to owen $filePath"
        # $sourceLine | Out-File -Append -Encoding $encoding $filePath  # _vimrc will be utf8 format
        Switch ($action) {
        "add"     { $newText = $text + @($sourceLine) }
        "insert"  { $newText = @($sourceLine) + $text }
        default   { fmt_error "AddHook: Unknow action $action"; return}
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
        fmt_error "AddStartupTask() fail, $filePath do not exists"
        return
    }
    "Add Startup Task $filePath"
    $initd = "$Env:OwenInstallDir/etc/init.d"
    Mkdir-P $initd
    CreateShortCutToDir $filePath $initd
}

Function MakeAll() {
    # Make
    fmt_info "Compiling ahk and go"
    if ($file = Get-ChildItem -Recurse "previewer.go") {  # preview for lf
        go build -o "bin/$($file.basename).exe" "$file"
    }
    if ($file = Get-ChildItem -Recurse "keyremap.ahk") {
        ahk2exe "$file" "bin\$($file.basename).exe"   # must be backslash for ahk2exe
    }
    if ($file = Get-ChildItem -Recurse "easy-marker.ahk") {
        ahk2exe "$file" "bin\$($file.basename).exe"   # must be backslash for ahk2exe
    }
    if ($file = Get-ChildItem -Recurse "xshell-proxy.ps1") {
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
    # DeployConfigDir  "etc/lf"             "$Env:LF_CONFIG_HOME"
    DeployConfigDir  "etc/lf"             "$Env:LOCALAPPDATA/lf"
    DeployConfigDir  "etc/profile"        "$Env:OwenInstallDir/etc/profile"
    DeployConfigDir  "etc/common"         "$Env:OwenInstallDir/etc/common"
    DeployConfigDir  "etc/typora"         "$Env:APPDATA/Typora/themes/owen"

    "--- Write hook to vim and powrshell profile, because vim, profile can not be custom path"
    AddHookToConfigFile "$HOME\_vimrc"  "source $Env:OwenInstallDir/etc/vim/vimrc"  '"' ""  "utf8"          # vimrc must be utf8 for parsing
    AddHookToConfigFile "$Profile"      ". $Env:OwenInstallDir/etc/profile/profile.ps1; If (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }"
    AddHookToConfigFile "$Env:APPDATA/Typora/themes/github.css" '@import "owen/owen-auto-number.css";'  "/*" "*/"   "utf8" "insert"

    # # v2ray
    # $file = Get-ChildItem $env:OwenInstallDir -Recurse "pac.txt"
    # cp $file "D:\owen\scoop\apps\v2rayN\current\guiConfigs\pac.txt"

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
    AddStartupTask "$(Get-AppExe 'qq')"
    AddStartupTask "$(Get-AppExe 'proxifier')"
    AddStartupTask "$(Get-AppExe 'V2rayN')"
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

