
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
    $MarkLine="# -- Owen configed -----" 
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

Function BootstrapWin() {
    If (!(test-path D:\.local\win10\ -PathType Container)) {
		New-Item -ItemType Directory -Path D:\.local\win10\ | Out-Null
    }

	cp etc\vim\vim8.vimrc     D:\.local\_vimrc
	cp -r -Force etc\win10\*  D:\.local\win10\

    TryConfig "$HOME\_vimrc"  "source D:\.local\_vimrc"  '"'  "utf8"  # vimrc must be utf8 for parsing
    TryConfig "$profile"      ". D:\.local\win10\psh\profile.ps1" 
}

BootstrapWin

# Schedule Apps
# Startup Apps
