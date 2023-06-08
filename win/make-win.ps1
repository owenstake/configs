
Function EnvSetup() {
    $Env:OwenInstallDir = "D:\.local"
    [Environment]::SetEnvironmentVariable('OwenInstallDir', $Env:OwenInstallDir, 'User')
    $ENV:LF_CONFIG_HOME = "$Env:OwenInstallDir\etc\lf"
    [Environment]::SetEnvironmentVariable('LF_CONFIG_HOME', $Env:LF_CONFIG_HOME, 'User')
    $Env:WEIYUN = "D:\owen\weiyun"
    [Environment]::SetEnvironmentVariable('WEIYUN', $Env:WEIYUN, 'User')
}

Function fmt_info {
	Write-Host $args -BackgroundColor DarkCyan
}

Function fmt_warn {
    Write-Host $args -ForegroundColor Yellow -BackgroundColor DarkGreen
}

Function fmt_error {
	Write-Host $args -BackgroundColor DarkRed
}

Function New-Item-IfNoExists($path,$type="File") {
	if ( !(Test-Path -Path $path) ) {
		New-Item -Path $path -ItemType $type -Force | Out-Null
	}
}

Function Mkdir-P($dir) {
    New-Item-IfNoExists $dir "Directory"
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

Function Test-AppExistsInScoop($appName) {
    $scoopInfo = scoop export | ConvertFrom-Json
    If ($scoopInfo.apps | where-object -FilterScript {$PSitem -match "$appName"}) {
        return $true
    } else {
        return $false
    }
}

Function CreateShortCut([string]$SourceFilePath,$ShortcutPath) {
    # $SourceFilePath       = ( Get-Item -Path "$SourceFilePath" ).FullName
    # $SourceFileName       = ( Get-Item -Path "$SourceFilePath" ).BaseName
    # $ShortcutPath         = "$ShortcutDir\$SourceFileName.lnk"
    $WScriptObj           = New-Object -ComObject ("WScript.Shell")
    $shortcut             = $WscriptObj.CreateShortcut($ShortcutPath)
    $shortcut.TargetPath  = $SourceFilePath
    $shortcut.WindowStyle = 1
    # $ShortCut.Hotkey      = "CTRL+SHIFT+T";
    $shortcut.Save()
}

Function CreateShortCutToDir($sourceFilePath,$shortcutDir) {
    $baseName     = $(Get-Item $sourceFilePath).Name
    $shortcutPath = "$ShortcutDir/${baseName}.lnk"
    CreateShortCut $sourceFilePath $shortcutPath
}

Function ahk2exe($ahkFile, $exeFile) {
    ahk2exe.exe /silent /in $ahkFile /out $exeFile /base "$env:scoop\apps\autohotkey1.1\current\Compiler\Unicode 64-bit.bin"
}

Function DeployConfigDir($srcDir, $dstDir) {
    "Deploy $srcDir to $dstDir"
    Mkdir-P $dstDir
	cp -r -Force $srcDIr/* "$dstDir"
}

Function EnableStartupTask($exePath) {
    $initd = "$Env:OwenInstallDir/etc/init.d"
    Mkdir-P $initd
    CreateShortCutToDir $exePath $initd
}

Function MakeAll() {
    # Make
    fmt_info "Compiling ahk and go"
    if ($file = Get-ChildItem -Recurse "keyremap.ahk") {
        ahk2exe $file bin\keyremap.exe
    }
    if ($file = Get-ChildItem -Recurse "easymarker.ahk") {
        ahk2exe $file bin\easymarker.exe
    }
    if ($file = Get-ChildItem -Recurse "previewer.go") {  # preview for lf
        go build -o bin\previewer.exe $file 
    }
    # if ($file = Get-ChildItem -Recurse "owen-startup.ps1") {
    #     ps2exe $file "bin\owen-startup.exe"
    # }
}

Function MakeClean() {
    rm bin
}

Function MakeUninstall() {
    rm $env:OwenInstallDir
}

Function MakeInstall() {
    # New-Item-IfNoExists  "$Env:OwenInstallDir"  "Directory"
    "--- Env setup ----"
    EnvSetup

    "--- Deploy Config File ----"
    DeployConfigDir "../common/etc/vim"  "$Env:OwenInstallDir/etc/vim"
    DeployConfigDir "etc/lf"      "$Env:OwenInstallDir/etc/lf"
    DeployConfigDir "etc/profile" "$Env:OwenInstallDir/etc/profile"

    "--- Write hook to vim and powrshell profile, because vim, profile can not be custom path"
    AddHookToConfigFile "$HOME\_vimrc"  "source $Env:OwenInstallDir/etc/vim/vimrc"  '"'  "utf8"          # vimrc must be utf8 for parsing
    # AddHookToConfigFile "$Profile"      ". $Env:OwenInstallDir/etc/profile/profile.ps1; If (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }"
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
    EnableStartupTask "$(GetAppExe 'qq')"
    $file = Get-ChildItem "$Env:OwenInstallDir" -Recurse keyremap.ahk
    EnableStartupTask $file.FullName
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

