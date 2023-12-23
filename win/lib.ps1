### Function ########
Function fmt_info {
	Write-Host $args -BackgroundColor DarkCyan
}

Function fmt_warn {
    Write-Host $args -ForegroundColor Yellow -BackgroundColor DarkGreen
}

Function fmt_error {
	Write-Host $args -BackgroundColor DarkRed
}

Function SetEnvVar($envName, $value) {
    if ($envVar = Get-ChildItem -Path Env:$envName -errorAction silentlyContinue ) {
        if ($envVar.Value -eq $value) {
            "env $envName already set to $value"
            return
        }
    }
    Set-Item -Path "env:$envName" -Value "$value"
    [Environment]::SetEnvironmentVariable("$envName", $value, 'User')
    "env $envName set to $value"
}

Function New-Item-IfNoExists($path,$type="File") {
	if ( !(Test-Path -Path $path) ) {
		New-Item -Path $path -ItemType $type -Force | Out-Null
	}
}

Function Mkdir-P($dir) {
    New-Item-IfNoExists $dir "Directory"
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
    $WScriptObj           = New-Object -ComObject ("WScript.Shell")
    $shortcut             = $WscriptObj.CreateShortcut($ShortcutPath)
    $shortcut.TargetPath  = $SourceFilePath
    $shortcut.WindowStyle = 1
    $shortcut.Save()
}

Function CreateShortCutToDir($sourceFilePath,$shortcutDir) {
    $baseName     = $(Get-Item $sourceFilePath).Name
    $shortcutPath = "$ShortcutDir/${baseName}.lnk"
    CreateShortCut $sourceFilePath $shortcutPath
}

Function ahk2exe($ahkFile, $exeFile) {
    ahk2exe.exe /in $ahkFile /out $exeFile /base "$env:scoop\apps\autohotkey1.1\current\Compiler\Unicode 64-bit.bin"
}

Function Test-CommandExists {
	Param ($command)
    If (Get-Command $command -ErrorAction SilentlyContinue) {
        return $true
    } else {
        return $false
    }
}

Function EnvPathUserInsertIfNoExists($pos, $item) {
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
    $Path_Machine = [Environment]::GetEnvironmentVariable('Path','Machine')
    $Path_User    = [Environment]::GetEnvironmentVariable('Path','User')
    Switch ($pos) {
        -1 {$Path_User = $Path_User + ";" +  $item}
        0 {$Path_User = $item + ";" + $Path_User}
        Default { Write-Error "unknow pos $pos"; return }
    }
    [Environment]::SetEnvironmentVariable('PATH', $Path_User, 'User')
    $Env:Path = $Path_Machine + $Path_User
}

Function IsUosWin() {
    if ($Env:UserName.contains("Administrator")) {
        echo "In UosWin"
        return $true
    }
    return $false
}

