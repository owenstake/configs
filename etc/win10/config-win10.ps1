###########################################################
# Init win10 config
###########################################################

"------ Show system info ----"
systeminfo

"------ Enable Remote Desktop using PowerShell ----"
"Ref - https://exchangepedia.com/2016/10/enable-remote-desktop-rdp-connections-for-admins-on-windows-server-2016.html"

"1.Enable Remote Desktop connections"
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0

"2.Enable Network Level Authentication"
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name "UserAuthentication" -Value 1

"3.Enable Windows firewall rules to allow incoming RDP"
Enable-NetFirewallRule -DisplayGroup "远程桌面"          # for chn
# Enable-NetFirewallRule -DisplayGroup "Remote Desktop"  # for eng

"------ Enable Hyper V manager----"
"Ref - https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v"
"Ref - https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/try-hyper-v-powershell"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

# Add-WindowsFeature RSAT-Hyper-V-Tools -IncludeAllSubFeature



"------ Install WSL using PowerShell ----"
# [Install WSL | Microsoft Learn](https://learn.microsoft.com/en-us/windows/wsl/install )
wsl --install

