. ./lib.ps1

Function EnvSetup() {
    SetEnvVar "OwenInstallDir" "D:\.local"
    SetEnvVar "LF_CONFIG_HOME" "$Env:OwenInstallDir\etc\lf"
    SetEnvVar "WEIYUN"         "D:\owen\weiyun"
}

Function AddHookToConfigFile($filePath, $msg, $commentMark="#", $encoding="unicode" ) {
    $MarkLine="$commentMark -- Owen configed -----"
    New-Item-IfNoExists $filePath
    if (!(Select-String -Pattern "$MarkLine" -Path "$filePath")) {
        fmt_info "owen $filePath is configing"
        $rawText = "
            $MarkLine
            # -- Owen $filePath config -----
            $msg
            # -- end Owen $filePath config -----
        "
        # remove leading space and replace comment mark if need
        $text = ($rawText -replace "\n\s+","`n" -replace "\n#","`n$commentMark").Trim()
        $text | out-file -Append -Encoding $encoding $filePath     # _vimrc will be utf8 format
    } else {
        fmt_info "owen $filePath is configed already"
    }
}

Function DeployConfigDir($srcDir, $dstDir) {
    "Deploy $srcDir to $dstDir"
    Mkdir-P $dstDir
	cp -r -Force $srcDIr/* "$dstDir"
}

Function AddStartupTask($exePath) {
    "Add Startup Task $exePath"
    $initd = "$Env:OwenInstallDir/etc/init.d"
    Mkdir-P $initd
    CreateShortCutToDir $exePath $initd
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
    DeployConfigDir  "etc/lf"             "$Env:LF_CONFIG_HOME"
    DeployConfigDir  "etc/lf"             "$Env:LOCALAPPDATA/lf"
    DeployConfigDir  "etc/profile"        "$Env:OwenInstallDir/etc/profile"
    DeployConfigDir  "etc/common"         "$Env:OwenInstallDir/etc/common"

    "--- Write hook to vim and powrshell profile, because vim, profile can not be custom path"
    AddHookToConfigFile "$HOME\_vimrc"  "source $Env:OwenInstallDir/etc/vim/vimrc"  '"'  "utf8"          # vimrc must be utf8 for parsing
    AddHookToConfigFile "$Profile"      ". $Env:OwenInstallDir/etc/profile/profile.ps1; If (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }"

    # # v2ray
    # $file = Get-ChildItem $env:OwenInstallDir -Recurse "pac.txt"
    # cp $file "D:\owen\scoop\apps\v2rayN\current\guiConfigs\pac.txt"

    # # typora config
    # $file = Get-ChildItem $env:OwenInstallDir -Recurse "owen-auto-number"
    # cp $file $Env:APPDATA/Typora/themes/owen-auto-number.css 
    # $TYPORA_CSS_REF = '@import "owen-auto-number.css";    /* owen config */'
    # $TYPORA_THEME_FILE = "$Env:APPDATA/Typora/themes/github.css"
    # AddHookToConfigFile "$TYPORA_THEME_FILE" "$TYPORA_CSS_REF"
    # sudo sed -i '/owen config/d' $TYPORA_THEME_FILE
    # sudo sed -i "1s:^:$TYPORA_CSS_REF\n:" $TYPORA_THEME_FILE

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
    AddStartupTask "$(GetAppExe 'qq')"
    AddStartupTask "$(GetAppExe 'proxifier')"
    $file = Get-ChildItem "$Env:OwenInstallDir" -Recurse keyremap.ahk
    AddStartupTask $file.FullName
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

