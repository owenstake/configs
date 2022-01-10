###########################################################
# Init WSL IP and Forward in win10
# we must config this script as a start script in win10 as D:/.local/win10/init-wsl.ps1
###########################################################

# Param( [Parameter(Mandatory = $True)][string] $WSLIP, [Parameter(Mandatory = $True)][string] $WINIP )

##### get privillege #############################################################
# Run this .ps1 as ADMIN with $args
# Must pass $arges into the command.
# https://stackoverflow.com/questions/7690994/running-a-command-as-administrator-using-powershell
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs    `
        "   `
            -NoProfile -ExecutionPolicy Bypass -Command `" cd '$pwd'; & '$PSCommandPath' $args `"      `
        " ;
    exit;
}
##### end of get privillege #############################################################

##### functions ################
function wsl_add_proxy($DESCRIPTION, $WIN_PORT, $WSL_PORT) {
    "wsl portproxy for $DESCRIPTION, win port = $WIN_PORT, sock port = $WSL_PORT"
    # "portproxy clear"
    netsh interface portproxy delete v4tov4 listenport=$WIN_PORT listenaddress=0.0.0.0
    # "portproxy add"
    netsh interface portproxy add v4tov4 listenport=$WIN_PORT listenaddress=0.0.0.0 connectport=$WSL_PORT connectaddress=wslhost
    # "portproxy add firewall"
    netsh advfirewall firewall add rule name=WSL2 dir=in action=allow protocol=TCP localport=$WIN_PORT
}
##### end of functions ################

"--------------------- var define -------------------------------------------"
$WSLIP=$args[0] 
$WINIP=$args[1] 
$REMOTEHOST=$args[2] 
$CLOUDHOST=$args[3] 

"WSL IP = " + $WSLIP
"WIN IP = " + $WINIP
##### end of var define #################

# Add an IP address in Ubuntu, $WSLIP, named eth0:1
# i.e. wsl -u root ip addr add 192.168.50.1/24 broadcast 192.168.50.255 dev eth0 label eth0:1
wsl -u root ip addr add $WSLIP/24 dev eth0 label eth0:1

# Add an IP address in Win10, $WINIP
netsh interface ip add address "vEthernet (WSL)" $WINIP 255.255.255.0

"--------------------- add port proxy in wsl2 -------------------------------------------"
# ssh config port $WSL_SSHD_PORT - see /etc/ssh/sshd_config
$WSL_SSHD_PORT="3322"          # for ssh
$PROXY_HTTP_PORT="38080"
$PROXY_SOCK_PORT="38081"

wsl_add_proxy "ssh" 3322 22
wsl_add_proxy "goproxy for http" $PROXY_HTTP_PORT $PROXY_HTTP_PORT
wsl_add_proxy "goproxy for sock" $PROXY_SOCK_PORT $PROXY_SOCK_PORT

"Show port proxy wsl2 "
netsh interface portproxy show all

" -------------------- FIREWALL ---------------------------------------- "
# for mobax xserver
netsh advfirewall firewall add rule name=WSL2 dir=in action=allow protocol=TCP localport=6000

"Add firewall wsl2 rules for icmp ping"
netsh advfirewall firewall set rule name="文件和打印机共享(回显请求 - ICMPv4-In)" new enable=yes
netsh advfirewall firewall set rule name="虚拟机监控(回显请求- ICMPv4-In)" new enable=yes

# "Show firewall wsl2 rules"
# https://support.microsoft.com/en-us/topic/44af15a8-72a1-e699-7290-569726b39d4a
# netsh advfirewall firewall show rule name=WSL2
# netsh advfirewall firewall show rule name="文件和打印机共享(回显请求 - ICMPv4-In)"
# netsh advfirewall firewall show rule name="虚拟机监控(回显请求- ICMPv4-In)"

"TODO: start firewall "
# netsh advfirewall set currentprofile state on

"--------------------- Modify hosts - this require admin privillege ----------------------------------"
# --%  https://stackoverflow.com/questions/18923315/using-in-powershell
wsl --% sed -i '/wslhost/d' /mnt/c/Windows/System32/drivers/etc/hosts   # C:\Windows\System32\drivers\etc\hosts
wsl --% sed -i '/remotehost/d' /mnt/c/Windows/System32/drivers/etc/hosts   # C:\Windows\System32\drivers\etc\hosts
wsl --% sed -i '/cloudhost/d' /mnt/c/Windows/System32/drivers/etc/hosts   # C:\Windows\System32\drivers\etc\hosts
wsl "--%" "echo $WSLIP wslhost >> /mnt/c/Windows/System32/drivers/etc/hosts"   # "--%" is for >>
wsl "--%" "echo $REMOTEHOST remotehost >> /mnt/c/Windows/System32/drivers/etc/hosts"
wsl "--%" "echo $CLOUDHOST cloudhost >> /mnt/c/Windows/System32/drivers/etc/hosts"

wsl -u root sed -i '/wslhost/d'    /etc/hosts
wsl -u root sed -i '/remotehost/d' /etc/hosts
wsl -u root sed -i '/cloudhost/d'  /etc/hosts
wsl -u root "--%" "echo $WSLIP      wslhost    >> /etc/hosts"
wsl -u root "--%" "echo $REMOTEHOST remotehost >> /etc/hosts"
wsl -u root "--%" "echo $CLOUDHOST  cloudhost  >> /etc/hosts"

"-------------------- sshd start ------------------------"
wsl -u root /etc/init.d/ssh start

sleep 10
