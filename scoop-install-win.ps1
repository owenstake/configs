

# https://zhuanlan.zhihu.com/p/594363658
# https://gitee.com/glsnames/scoop-installer
# https://gitee.com/scoop-bucket

$WinVersion = (Get-WmiObject Win32_OperatingSystem).BuildNumber

Function fmt_info {
	Write-Host $args -BackgroundColor DarkCyan
}

Function fmt_warn {
    Write-Host $args -ForegroundColor Yellow -BackgroundColor DarkGreen
}

Function fmt_error {
	Write-Host $args -BackgroundColor DarkRed
}

Function Test-CommandExists {
	Param ($command)
    If (Get-Command $command -ErrorAction SilentlyContinue) {
        return $true
    } else {
        return $false
    }
	# $oldPreference = $ErrorActionPreference
	# $ErrorActionPreference = 'stop'
	# try {if(Get-Command $command){RETURN $true}}
	# Catch {fmt_error "$command does not exist"; RETURN $false}
	# Finally {$ErrorActionPreference=$oldPreference}
}

Function Test-AppExistsInScoop($appName) {
    $scoopInfo = scoop export | ConvertFrom-Json
    If ($scoopInfo.apps | where-object -FilterScript {$PSitem -match "$appName"}) {
        return $true
    } else {
        return $false
    }
}

Function Test-AppExistsInChoco($app) {
    $retArr = choco list --localonly $app
    return [int](($retArr[-1]).split()[0]) -ne 0
}

Function ScoopInstallApp($app) {
    If ( (Test-CommandExists scoop) -and  (Test-AppExistsInScoop "$app") ) { # ??
        return
    }
    # If ( (Test-CommandExists choco) -and  (Test-AppExistsInChoco $app) ) { # ??
    #     return
    # }

    scoop install $app
}

Function scoop-install {
    fmt_info "Scoop install apps"
	# fix ssl in tyy win10 server 2016 - 
	# TLS - https://learn.microsoft.com/zh-cn/dotnet/framework/network-programming/tls
	# [System.Net.ServicePointManager]::SecurityProtocol += [System.Net.SecurityProtocolType]::Tls12;
	$scoopInstallDir="D:\owen\scoop"
	
	If (!(Test-CommandExists scoop)) {
		# self-define for scoop
		$env:SCOOP=$scoopInstallDir
		[environment]::setEnvironmentVariable('SCOOP',$env:SCOOP,'User')

		# $env:SCOOP_GLOBAL='D:\apps'
		# [environment]::setEnvironmentVariable('SCOOP_GLOBAL',$env:SCOOP_GLOBAL,'Machine')

		# install scoop - china user see this => https://gitee.com/glsnames/scoop-installer
		Set-ExecutionPolicy RemoteSigned -scope CurrentUser
		iwr -useb scoop.201704.xyz | iex	
	} else {
		fmt_info "Scoop cmd exists"
	}

	$lastApp="scoop-completion"
	If (Test-Path $env:scoop\apps\$lastApp) {
		If (scoop info $lastApp) {
			fmt_warn "All apps is already installed in scoop"
			return
		} else {
			fmt_warn "All apps dir is exists but not installed in scoop."
			# Write-Host "You can run `scoop reset *` to restore scoop apps"
			$confirmation = Read-Host "Do you want to recover it? [Y]/N"
			if ($confirmation -ne 'n') {
				scoop reset *
				return
			} else {
				# fmt_info "scoop installing app..."
			}
		}
	}

	fmt_info "App is installing in Scoop. Dir is $scoopInstallDir"
	
    # git install first for scoop
	if (!(Test-CommandExists git)) {  # git maybe install outside
		scoop install git
	}

	# scoop install Aria2

	if (!(Test-CommandExists git)) {
		fmt_error "Please install git first for bucket update"
		return -1
	} else {
		if (scoop bucket list | findstr version) {
			fmt_warn "Bucket is updated"
		} else {
			fmt_info "Updating bucket - not neccesary. final download is still github."
			scoop bucket rm main
			scoop bucket rm extras
			scoop bucket rm versions
			scoop bucket add main     https://gitee.com/scoop-bucket/main.git
			scoop bucket add extras   https://gitee.com/scoop-bucket/extras.git
			scoop bucket add versions https://gitee.com/scoop-bucket/versions.git
		}
	}

	# autohotkey V1 need manual installation
    If (!(Test-AppExistsInScoop psfzf)) {
        scoop install psfzf@2.4.0
        scoop hold psfzf  # no update psfzf. psfzf@latest is broken.
    }
	
	# CLI handy tool
	$appstr = "
		gow sudo vim-tux less bat tre-command recycle-bin file # CLI basic tool
        lua fd ripgrep z.lua fzf  extras/pscolor               # CLI super tool
		autohotkey ffmpeg  python nodejs-lts                   # CLI program envir
		snipaste ScreenToGif notepadplusplus                   # UI simple tool
		# UI tool
		foxit-reader v2rayN typora vscode draw.io googlechrome
		qq wechat foxit-reader mobaxterm foxmail
		tor-browser firefox typora
	"
	If ($WinVersion -gt 18362) {
		$appstr += " windows-terminal"
	}
    # winget worked in winversion >= 16299
	$appstr = $appstr -replace "#.*"
	$apps = $appstr.trim() -split '\s+'
	fmt_info "installing apps =>"
	fmt_info "apps count is" $apps.count
	fmt_info $apps

	scoop install $apps
	scoop install $lastApp
}

Function chocolatey-install() {
    fmt_info "Choco install apps"
    # If ($WinVersion -ge 17763) {
    #     fmt_warn "Use Winget instead of choco since Win Version $WinVersion >= 17763)  (WindSowsServer2019)"
    #     return
    # }
    # install chocolatey
    If (!(Test-CommandExists choco)) {
        # need proxy and admin priviledge
        Start-Process powershell -verb runas -ArgumentList "
            -Command `"
            Set-ExecutionPolicy Bypass -Scope Process -Force;
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
            iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));
            cmd /c pause
            "
    }
    $appstr = "
    "
	$appstr = $appstr -replace "#.*"
	$apps = $appstr.trim() -split '\s+'
    If (!($apps)) {
        return
    } else {
        sudo choco install $apps
    }
}

Function winget-install() {
    fmt_info "winget install apps"
    If ($WinVersion -lt 17763) {
        fmt_warn "At least WindowsServer2019(17763) is required to use winget."
        return
    }
    If (!(Test-CommandExists winget)) {
        scoop install winget wingetUI
    }
    $appstr = "
        Sogou.SogouInput  Tencent.WeiyunSync  Baidu.BaiduNetdisk
        Thunder.Xmp  Tencent.QQMusic
    "
	$appstr = $appstr -replace "#.*"
	$apps = $appstr.trim() -split '\s+'

	fmt_info "installing apps =>"
	fmt_info "apps count is" $apps.count
	fmt_info $apps

    Foreach ($app in $apps) {
        winget install --id="$app" -e --no-upgrade -l "d:\owen\winget"
    }
}

Function main {
	.\bootstrap-win.ps1
	scoop-install
    chocolatey-install
    winget-install
}

$time = Measure-Command { main }
fmt_info "Time elasped => $time "

# cmd history - $env:APPDATA\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
# .net-framework - https://dotnet.microsoft.com/zh-cn/download/dotnet-framework/thank-you/net472-web-installer
# $env:ALL_PROXY="http://127.0.0.1:10809"
# scoop config proxy http://127.0.0.1:10809
# scoop config rm proxy

# restore scoop all apps
# scoop reset *

# v2rayN - subscribe - https://subbs.susuda.sslcdnapp.net/link/rfB6U0hYByqVcNwm?sub=3&extend=1

# vimrc
# let &pythonthreedll = 'D:\scoop\apps\python\3.11.3\python311.dll'

# 24-bit Color may be not support in the Windows 10 console (Windows 10 release 1703 onwards)
# https://devblogs.microsoft.com/commandline/24-bit-color-in-the-windows-console/





