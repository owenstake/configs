###########################################################
# Init WSL IP and Forward in win10
# we must config this script as a start script in win10 as D:/.local/win10/init-wsl.ps1
###########################################################

# Param( [Parameter(Mandatory = $True)][string] $WSLIP, [Parameter(Mandatory = $True)][string] $WINIP )

##################################################################
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
##################################################################

$WSLIP=$args[0] 
$WINIP=$args[1] 

"WSL IP = " + $WSLIP
"WIN IP = " + $WINIP

# Add an IP address in Ubuntu, $WSLIP, named eth0:1
# i.e. wsl -u root ip addr add 192.168.50.1/24 broadcast 192.168.50.255 dev eth0 label eth0:1
wsl -u root ip addr add $WSLIP/24 dev eth0 label eth0:1

# Add an IP address in Win10, $WINIP
netsh interface ip add address "vEthernet (WSL)" $WINIP 255.255.255.0

$LISTEN_PORT="3322"
# delete first for no duplicated
"--------------------- portproxy wsl2 -------------------------------------------"
"Deleting portproxy wsl2 "
netsh interface portproxy delete v4tov4 listenport=$LISTEN_PORT listenaddress=0.0.0.0

# Add forward rule table for ssh port $LISTEN_PORT. ssh config port $LISTEN_PORT - see /etc/ssh/sshd_config
"Adding portproxy wsl2 "
netsh interface portproxy add v4tov4 listenport=$LISTEN_PORT listenaddress=0.0.0.0 connectport=22 connectaddress=wslhost

# netsh interface portproxy add v4tov4 listenport=6010 listenaddress=0.0.0.0 connectport=6010 connectaddress=wslhost

# show current proxy port
"Show portproxy wsl2 "
netsh interface portproxy show all

" -------------------- FIREWALL ---------------------------------------- "
# delete firewall first for no duplicated.
"Deleting firewall wsl2 rules"
netsh advfirewall firewall delete rule name=WSL2

"Adding firewall wsl2 rules for $LISTEN_PORT"
netsh advfirewall firewall add rule name=WSL2 dir=in action=allow protocol=TCP localport=$LISTEN_PORT

"Add firewall wsl2 rules for icmp ping"
netsh advfirewall firewall set rule name="文件和打印机共享(回显请求 - ICMPv4-In)" new enable=yes
netsh advfirewall firewall set rule name="虚拟机监控(回显请求- ICMPv4-In)" new enable=yes

"Show firewall wsl2 rules"
# netsh advfirewall firewall show rule name="文件和打印机共享(回显请求 - ICMPv4-In)"
# netsh advfirewall firewall show rule name="虚拟机监控(回显请求- ICMPv4-In)"

"--------------------- Modify hosts - this require admin privillege ----------------------------------"
# --%  https://stackoverflow.com/questions/18923315/using-in-powershell
wsl --% sed -i '/wslhost/d' /mnt/c/Windows/System32/drivers/etc/hosts   # C:\Windows\System32\drivers\etc\hosts
wsl "--%" "echo $WSLIP wslhost >> /mnt/c/Windows/System32/drivers/etc/hosts"

"-------------------- sshd start ------------------------"
wsl -u root /etc/init.d/ssh start

sleep 10
