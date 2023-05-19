
Function fmt_info {
	Write-Host $args -BackgroundColor DarkCyan
}

Function fmt_warn {
    Write-Host $args -ForegroundColor Yellow -BackgroundColor DarkGreen
}

Function fmt_error {
	Write-Host $args -BackgroundColor DarkRed
}

Function TryConfig($file, $msg, $commentMark="#", $encoding="unicode" ) {
    $MarkLine="$commentMark -- Owen configed -----"
	if (!(Test-Path -Path $file )) {
		New-Item -ItemType File -Path $file | Out-Null
	}
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

$DirStartUp = '~\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup'

Function SetScoopAppStartUp($app) {
    $DirScoopAppsDir = '~\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps'
    # CreateShortCut "$DirScoopAppsDir\$app.lnk" "$DirStartUp\$app.lnk"
    cp "$DirScoopAppsDir\$app.lnk" "$DirStartUp\"
}
Function SetFileToStartUp($SourceFilePath) {
    $SourceFilePath       = ( Get-Item -Path "$SourceFilePath" ).FullName
    $SourceFileName       = ( Get-Item -Path "$SourceFilePath" ).Name
    CreateShortCut $SourceFilePath $DirStartUp\$SourceFileName.lnk
}

Function SetStartUp() {
    SetScoopAppStartUp qq
    CreateShortCut "D:\.local\win10\psh\keyremap.ahk" $DirStartUp
}

Function BootstrapWin() {
    If (!(test-path D:\.local\win10\ -PathType Container)) {
		New-Item -ItemType Directory -Path D:\.local\win10\ | Out-Null
    }

	cp etc\vim\vim8.vimrc     D:\.local\_vimrc
	cp -r -Force etc\win10\*  D:\.local\win10\

    # gtags config
    If (Test-AppExistsInScoop("global")) {
        If (!(test-path $env:scoop\share\gtags -PathType Container)) {
            New-Item -ItemType Directory -Path $env:scoop\share\gtags | Out-Null
        }
        cp $env:scoop\apps\global\current\share\gtags\gtags.conf $env:scoop\share\gtags\
    }
    TryConfig "$HOME\_vimrc"  "source D:\.local\_vimrc"  '"'  "utf8"  # vimrc must be utf8 for parsing
    TryConfig "$profile"      ". D:\.local\win10\psh\profile.ps1" 
}

BootstrapWin

# Schedule Apps
# Startup Apps

