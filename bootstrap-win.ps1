
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

Function TryConfig($file, $msg, $commentMark="#", $encoding="unicode" ) {
    $MarkLine="$commentMark -- Owen configed -----"
    New-Item-IfNoExists $file
    if (!(Select-String -Pattern "$MarkLine" -Path "$file")) {
        fmt_info "owen $file is configing"
        $rawText = "
            $MarkLine
            # -- Owen $file config -----
            $msg
            # -- end Owen $file config -----
        "
        # remove leading space and replace comment mark if need
        $text = ($rawText -replace "\n\s+","`n" -replace "\n#","`n$commentMark").Trim()
        $text | out-file -Append -Encoding $encoding $file     # _vimrc will be utf8 format
    } else {
        fmt_info "owen $file is configed already"
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

Function CreateShortCut($SourceFilePath,$ShortcutPath) {
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

Function EnvPathInsertAtHeadIfNoExists($item) {
    If (!(Test-Path $item)) {
        Write-Error "Args is invalid. $item"
        return
    }
    $paths = $env:path -split ";"
    Foreach($p in $paths) {
        If ($p -eq "$item") {
            return
        }
    }
    $env:path = $item + ";" + $env:path
    [Environment]::SetEnvironmentVariable('PATH', $Env:PATH, 'User')
}

Function BootstrapWin() {
    New-Item-IfNoExists  D:\.local\win10\       Directory
    New-Item-IfNoExists  $env:LOCALAPPDATA\lf\  Directory

	cp etc\vim\vim8.vimrc     D:\.local\_vimrc
	cp -r -Force etc\lf\*     $env:LOCALAPPDATA\lf\  # -force for override file but no create dir
	cp -r -Force etc\win10\*  D:\.local\win10\

    TryConfig "$HOME\_vimrc"  "source D:\.local\_vimrc"  '"'  "utf8"  # vimrc must be utf8 for parsing
    TryConfig "$profile"      ". D:\.local\win10\psh\profile.ps1; If (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }"

    # setup startup tasks
    $DirStartUp = '~\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup'
    cp etc\win10\owen-startup.cmd $DirStartUp\ -Force   # add win10 startup hook. Real Startup script is EntryAtLogOn

    # can be placed in install script
    # Path setting. gtags config
    # for search gtags config file
    If (Test-Path "$env:scoop\apps\global\current\bin") {
        EnvPathInsertAtHeadIfNoExists("$env:scoop\apps\global\current\bin")
    }
    # Registry setting
    # Set 双拼
    $registryPath = "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\InputMethod\Settings\CHS\"
    $value = get-itemproperty -Path $registryPath -Name 'Enable double pinyin'
    If (!$value.'Enable Double Pinyin') {
        if ($file = Get-ChildItem -Recurse "xiaohe-shuangpin.reg") {
            explorer.exe $file
        } else {
            fmt_error "No found shuangpin.reg"
        }
    }
}

BootstrapWin

# Schedule Apps
# Startup Apps

