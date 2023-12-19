Set-Location $pscommandpath/..

. ./lib.ps1
# https://zhuanlan.zhihu.com/p/594363658
# https://gitee.com/glsnames/scoop-installer
# https://gitee.com/scoop-bucket

### Global var ########
if ((Get-Volume).DriveLetter -contains "d"){
    $scoopInstallDir="D:\owen\scoop"
} else {
    $scoopInstallDir="~/owen/scoop"
}

$isUosWin = IsUosWin
if ($isUosWin) {
    $miniInstall=$true
}

# depend on nothing

# Configure String
$WinVersion = (Get-WmiObject Win32_OperatingSystem).BuildNumber
$script:wingetAppstr = "
    Sogou.SogouInput  Tencent.WeiyunSync  
    Thunder.Xmp       Thunder.Thunder
    "

$script:scoopAppstr1 = "
    # Install first
    7zip autohotkey1.1 vim-tux xray v2rayN vscode
    $(If ($WinVersion -gt 18362) { "windows-terminal oh-my-posh" } else { "cmder" })
"

$script:scoopCliAppstr1 = "
    gow sudo  less bat tre-command recycle-bin file    # CLI basic tool
    global go  lua python nodejs-lts winget git  # CLI program tool
    lf eza lua fd ripgrep z.lua fzf pscolor psfzf    # CLI super tool
    # Cli rust tool
    bat delta dust eza fd fselect grex hyperfine lf lsd tokei ripgrep sd
    starship watchexec zoxide 
    scoop-completion 
    "
$script:scoopCliAppstr2 = "
    ffmpeg SarasaGothic-SC
"
$script:scoopUiAppstr2 = "
    snipaste ScreenToGif notepadplusplus flux everything # UI simple tool 
    foxit-reader  draw.io googlechrome      # UI super tool
    # UI app
    wechat foxit-reader mobaxterm foxmail baiduNetdisk
	zotero tor-browser firefox typora obsidian HeidiSQL
    motrix
    proxifier               # L6Z8A-XY2J4-BTZ3P-ZZ7DF-A2Q9C 
    vcredist2022            # C++ lib Need by v2ray, windows-terminal
    "
$script:bucketsStr = "main extras versions nerd-fonts"

$script:psModuleAppstr = "
    ps2exe PSReadLine
    "

Function Test-ScoopApp($app) {
    return scoop list | Select-String "$app"
}

Function Get-AppsInstalledInScoop {
    return ,(scoop export | ConvertFrom-Json).apps.name
}

# Function GetAppsInstalledInChoco {
#     $chocoApps = @()
#     # scoop export | ConvertFrom-Json | Foreach { $chocoApps += $_.name }
#     return ,$chocoApps
# }

Function Get-AppsInstalledInWinget {
    $wingetApps = @()
    $tmpFile = New-TemporaryFile
    winget export --source winget  -o $tmpFile | out-null
    $wingetJson = Get-Content $tmpFile | ConvertFrom-Json
    Remove-Item $tmpFile
    return ,$wingetJson.Sources[0].Packages.PackageIdentifier
}

Function Get-AppsInstalledInPsModule {
    return ,(Get-Module -ListAvailable).name
}

# Function Test-AppExistsInChoco($app) {
#     $retArr = choco list --localonly $app
#     return [int](($retArr[-1]).split()[0]) -ne 0
# }

Function FormatAppsStr($appstr) {
	$appstr = $appstr -replace "#.*"
	$apps = $appstr.trim() -split '\s+'
    return ,$apps
}

Function Get-AppsNeedInstall($installer, $appStrs) {
    # $appStr = Get-Variable -scope Script -name "${appstr}" -ValueOnly # i.e. scoopAppstr
    $appsRequired = @()
    Foreach ($s in $appStrs) {
        $appsRequired    += FormatAppsStr $s
    }
    
    $appsInstalled   = & "Get-AppsInstalledIn${installer}"  # i.e GetAppsInstalledInScoop
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

Function Scoop-install {
    fmt_info "SCOOP: Start"
	# fix ssl in tyy win10 server 2016 - 
	# TLS - https://learn.microsoft.com/zh-cn/dotnet/framework/network-programming/tls
	# [System.Net.ServicePointManager]::SecurityProtocol += [System.Net.SecurityProtocolType]::Tls12;
    # Env setting
	If (!(Test-CommandExists scoop)) {
        fmt_info "SCOOP: Installing scoop first"
        SetEnvVar "SCOOP"       "$scoopInstallDir"
        SetEnvVar "scoopUiApps" "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps"
        If (Test-Path -pathtype Container $scoopInstallDir) {
            $need_restore = $true
        }
        # install scoop
        if ((whoami).contains("Administrator")) {
            iwr -useb scoop.201704.xyz -outfile 'install.ps1'
            ./install.ps1 -RunAsAdmin
            rm ./install.ps1
        } else {
            iwr -useb scoop.201704.xyz | iex
        }

        If (!(Test-CommandExists scoop)) {
            fmt_error "Fail to install scoop. Stop this script."
            exit -1
        }
        # Restore apps from exist install dir.
        if ($need_restore) {
            $prompt = "Do you want to restore scoop apps from $scoopInstallDir ? [y]/n"
            If (!(read-host -Prompt "$prompt") -eq "n") {
                scoop reset *
            }
        }
	} else {
        fmt_info "Scoop is already installed"
    }
	fmt_info "SCOOP: Installing Apps in $scoopInstallDir"
    # git install first for scoop
	if (!(Test-CommandExists git)) {  # git maybe install outside
		scoop install git
	}
	if (!(Test-CommandExists git)) {
        fmt_error "SCOOP: Git installation fail. Stop this script."
        exit -1
    } else {
        fmt_info "SCOOP: Git config"
        git config --global --add safe.directory '*'
        git config --global core.autocrlf false
        git config --global core.whitespace cr-at-eol
        git config --global http.sslVerify false
        git config --global http.https://github.com.proxy http://localhost:10809
    }
    # Bucket update. Require git installed.
    $buckets = FormatAppsStr $script:bucketsStr
    if (!(scoop bucket list | findstr $buckets[-1])) {
        fmt_info "SCOOP: Updating bucket source to Gitee for speeding up"
        Foreach ($b in $buckets) {
            scoop bucket rm  $b 6> $null
            scoop bucket add $b "https://gitee.com/scoop-bucket/$b.git"
        }
        scoop bucket add scoopet https://github.com/ivaquero/scoopet
    }
    # Install old version App
    if (!(Test-ScoopApp("psfzf"))) {
        scoop install psfzf@2.4.0
        scoop hold psfzf  # no update psfzf. psfzf@latest is broken.
    }
    # Install Apps
    if ($miniInstall) {
        $appsStrs = ($scoopAppstr1, $scoopCliAppstr1)
    } else {
        $appsStrs = ($scoopAppstr1, $scoopCliAppstr1,
                        $scoopCliAppstr2, $scoopUiAppstr2)
    }
    If ($apps = Get-AppsNeedInstall "SCOOP" $appsStrs ) {
        scoop install $apps
    }

    # Config Apps
    go env -w GOPROXY=https://goproxy.cn,direct
    # global config
    If (Test-Path "$env:scoop\apps\global\current\bin") {
        EnvPathInsertAtHeadIfNoExists("$Env:SCOOP\apps\global\current\bin")
    }

    return
}

Function Winget-install() {
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
    
    SetEnvVar "WINGET" "D:\owen\winget"
    # $env:WINGET="D:\owen\winget"
    # [environment]::setEnvironmentVariable('WINGET',$env:WINGET,'User')
    $apps = Get-AppsNeedInstall "WINGET" @($wingetAppstr)
    # Iterate install. winget has no batch install interface 2023.05.25
    Foreach ($app in $apps) {
        winget install --id="$app" -e --no-upgrade -l "$env:WINGET"
    }
}

Function Psmodule-Install {
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    $apps = Get-AppsNeedInstall "psModule"  @($psModuleAppstr)
    Install-Module -Name "PSreadline" -Scope CurrentUser -RequiredVersion 2.1.0   # reverse ops: uninstall-module
    Foreach ($app in $apps) {
        If (!(get-module $app)) {
            Install-Module -Name $app -Scope CurrentUser  # reverse ops: uninstall-module
        }
    }
}

Function Set-Shuangpin() {
    # Registry setting
    # 设置双拼
    $registryPath = "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\InputMethod\Settings\CHS\"
    $value = Get-Itemproperty -Path $registryPath -Name 'Enable double pinyin' -errorAction silentlyContinue
    If ((!$value) -Or (!$value.'Enable Double Pinyin')) {
        fmt_info "Set shuangpin"
        if ($file = Get-ChildItem -Recurse "xiaohe-shuangpin.reg") {
            explorer.exe $file
        } else {
            fmt_error "No found shuangpin.reg"
        }
    }
}

Function kuwo-app-install() {
    wget https://down.kuwo.cn/mbox/kwmusic_web_1.exe -outfile kw.exe
    ./kw.exe
    rm ./kw.exe
}

Function custom-install() {
    # kuwo-app-install
}

Function Wsl-install() {
    $prev = [Console]::OutputEncoding # Save current value.
    # Tell PowerShell to interpret external-program output as 
    # UTF-16LE ("Unicode") encoded.
    [Console]::OutputEncoding = [System.Text.Encoding]::Unicode
    if (!(wsl -v | Select-String "WSLg")) {  # if wsl is installed
        fmt_info "Install WSL"
        wsl --install --no-distribution
        fmt_warn "Reboot is need for wsl to take effect!"
    } else {
        if (wsl -v | Select-String "Error") {  # if wsl is installed
            fmt_warn "WSL is installed and reboot is need for wsl to take effect!"
        } else {
            fmt_info "WSL is installed."
        }
    }
    [Console]::OutputEncoding = $prev # Restore previous value.
}

Function Setup-ExecutionPolicy() {
    If ((Get-ExecutionPolicy -scope CurrentUser) -ne "RemoteSigned") {
        fmt_info "Set-ExecutionPolicy"
        Set-ExecutionPolicy RemoteSigned -scope CurrentUser
    }
}

Function main {
    Setup-ExecutionPolicy
    "This script just install app and config system"
    if (!($isUosWin)) {
        Wsl-install
    }
	Scoop-install
    # Chocolatey-install
    Psmodule-install
    Winget-install
    custom-install
    Set-Shuangpin
    New-Item ~/.root -Force
    "app config: vim, lf, "
}

$time = Measure-Command { main }
fmt_info "Total: Time elasped is $time"
