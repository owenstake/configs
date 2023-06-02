# https://zhuanlan.zhihu.com/p/594363658
# https://gitee.com/glsnames/scoop-installer
# https://gitee.com/scoop-bucket

# Configure String
$WinVersion = (Get-WmiObject Win32_OperatingSystem).BuildNumber
$script:wingetAppstr = "
    Sogou.SogouInput  Tencent.WeiyunSync  Baidu.BaiduNetdisk
    Thunder.Xmp       Tencent.QQMusic
    "
$script:scoopAppstr = "
    gow sudo vim-tux less bat tre-command recycle-bin file    # CLI basic tool
    global go autohotkey1.1 lua python nodejs-lts winget git  # CLI program tool
    lf lua fd ripgrep z.lua fzf pscolor psfzf                 # CLI super tool
    ffmpeg 
    7zip snipaste ScreenToGif notepadplusplus flux everything # UI simple tool 
    foxit-reader xray v2rayN vscode draw.io googlechrome      # UI super tool
    qq wechat foxit-reader mobaxterm foxmail SarasaGothic-SC
	zotero tor-browser firefox typora obsidian scoop-completion
    $(If ($WinVersion -gt 18362) { "windows-terminal oh-my-posh" } else { "cmder" })
    "
$script:bucketsStr = "main extras versions nerd-fonts"

$script:psModulestr = "
    ps2exe
    "

# function
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
}

Function GetAppsInstalledInScoop {
    return ,(scoop export | ConvertFrom-Json).apps.name
}

Function GetAppsInstalledInChoco {
    $chocoApps = @()
    # scoop export | ConvertFrom-Json | Foreach { $chocoApps += $_.name }
    return ,$chocoApps
}

Function GetAppsInstalledInWinget {
    $wingetApps = @()
    # scoop export | ConvertFrom-Json | Foreach { $chocoApps += $_.name }
    $tmpFile = New-TemporaryFile
    winget export --source winget  -o $tmpFile | out-null
    $wingetJson = Get-Content $tmpFile | ConvertFrom-Json
    Remove-Item $tmpFile
    return ,$wingetJson.Sources[0].Packages.PackageIdentifier
}

Function Test-AppExistsInChoco($app) {
    $retArr = choco list --localonly $app
    return [int](($retArr[-1]).split()[0]) -ne 0
}

Function FormatAppsStr($appstr) {
	$appstr = $appstr -replace "#.*"
	$apps = $appstr.trim() -split '\s+'
    return ,$apps
}

Function GetAppsNeedInstall($installer) {
    $appStr = get-variable -scope Script -name "${installer}Appstr" -valueonly # i.e. scoopAppstr
    $appsRequired    = FormatAppsStr $appStr
    $appsInstalled   = & "GetAppsInstalledIn${installer}"  # i.e GetAppsInstalledInScoop
    $appsNeedInstall = $appsRequired | where {$appsInstalled -NotContains $_}
    $appsInstalledButNotrequired = $appsInstalled | where {$appsRequired -NotContains $_}
    # Apps required
    fmt_info "${installer}: Required $($appsRequired.count) apps as follows."
    fmt_info "${installer}: $($appsRequired -join ' ')"
    # Apps installed
    fmt_info "${installer}: Already exists $($appsInstalled.count) apps as follows."
    fmt_info "${installer}: $($appsInstalled -join ' ')"
    # Apps installed but not in require
    If ($appsInstalledButNotrequired) {
        fmt_warn "${installer}: Already exists but not required $($appsInstalledButNotrequired.count) apps as follows."
        fmt_warn "${installer}: $($appsInstalledButNotrequired -join ' ')"
    }
    # Apps need install
    fmt_warn "${installer}: Install $($appsNeedInstall.count) apps as follows."
    fmt_warn "${installer}: $($appsNeedInstall -join ' ')"
    return ,$appsNeedInstall
}

Function scoop-install {
    fmt_info "SCOOP: Start"
	$scoopInstallDir="D:\owen\scoop"
	# fix ssl in tyy win10 server 2016 - 
	# TLS - https://learn.microsoft.com/zh-cn/dotnet/framework/network-programming/tls
	# [System.Net.ServicePointManager]::SecurityProtocol += [System.Net.SecurityProtocolType]::Tls12;
    # Env setting
	If (!(Test-CommandExists scoop)) {
        fmt_info "SCOOP: Installing scoop first"
		$env:SCOOP=$scoopInstallDir
		[environment]::setEnvironmentVariable('SCOOP',$env:SCOOP,'User')
        $env:scoopUiApps="$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps"
		[environment]::setEnvironmentVariable('SCOOPUIAPPS',$env:scoopUiApps,'User')
		# $env:SCOOP_GLOBAL='D:\apps'
		# [environment]::setEnvironmentVariable('SCOOP_GLOBAL',$env:SCOOP_GLOBAL,'Machine')
		# Install scoop for user. https://gitee.com/glsnames/scoop-installer
		Set-ExecutionPolicy RemoteSigned -scope CurrentUser
		iwr -useb scoop.201704.xyz | iex	
	}
	fmt_info "SCOOP: Installing Apps in $scoopInstallDir"
    # git install first for scoop
	if (!(Test-CommandExists git)) {  # git maybe install outside
		scoop install git
	}
	if (!(Test-CommandExists git)) {
        fmt_error "SCOOP: Git installation fail"
        return -1
    }
    # Bucket update. Require git installed.
    $buckets = FormatAppsStr $script:bucketsStr
    if (!(scoop bucket list | findstr $buckets[-1])) {
        fmt_info "SCOOP: Updating bucket source to Gitee for speeding up"
        Foreach ($b in $buckets) {
            scoop bucket rm  $b
            scoop bucket add $b "https://gitee.com/scoop-bucket/$b.git"
        }
    }
    # Install old version App
    If (!(Test-AppExistsInScoop psfzf)) {
        scoop install psfzf@2.4.0
        scoop hold psfzf  # no update psfzf. psfzf@latest is broken.
    }
    # Install Apps
    If ($apps = GetAppsNeedInstall("SCOOP")) {
        scoop install $apps
    }

    # config Apps
    go env -w GOPROXY=https://goproxy.cn,direct
    return
}

Function chocolatey-install() {
    fmt_info "CHOCO: Install Apps"
    If ($WinVersion -ge 17763) {
        fmt_warn "Use Winget instead of choco since Win Version $WinVersion >= 17763)  (WindSowsServer2019)"
        return
    }
    # Install chocolatey
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
    $chocoAppstr = ""
	fmt_info "CHOCO: Install $($apps.count)apps as follows.`n$apps"
    If ($apps = FormatAppsStr $chocoAppstr) {
        sudo choco install $apps
    }
}

Function winget-install() {
    fmt_info "WINGET: Start"
    If ($WinVersion -lt 17763) {
        fmt_warn "WINGET: requires windows system at least WindowsServer2019(17763)."
        return
    }
    If (!(Test-CommandExists scoop)) {
        fmt_error "WINGET: Please install scoop first!"
        return
    }
    If (!(Test-CommandExists winget)) {
        scoop install winget wingetUI
    }
    # Env
    $env:WINGET="D:\owen\winget"
    [environment]::setEnvironmentVariable('WINGET',$env:WINGET,'User')
    $apps = GetAppsNeedInstall("WINGET")
    # Iterate install. winget has no batch install interface 2023.05.25
    Foreach ($app in $apps) {
        winget install --id="$app" -e --no-upgrade -l "$env:WINGET"
    }
}

Function psmodule-install {
    $apps := FormatAppsStr $script:psModulestr
    Foreach ($app in $apps) {
        If (!(get-module $app)) {
            install-module $app
        }
    }
}

Function main {
	.\bootstrap-win.ps1
	scoop-install
    chocolatey-install
    winget-install
    psmodule-install
}

$time = Measure-Command { main }
fmt_info "Total: Time elasped is $time"

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





