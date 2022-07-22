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

################################
##### Functions ################
################################
function win_open_port($LIP, $LPORT, $CIP, $CPORT) {
    # "wsl portproxy for $DESCRIPTION, win port = $LPORT, sock port = $CPORT"
    # "portproxy clear" will be clear in outer
    # "portproxy add"
    netsh interface portproxy add v4tov4 listenport=$LPORT listenaddress=$LIP connectport=$CPORT connectaddress=$CIP
    # "portproxy add firewall"
    netsh advfirewall firewall add rule name=WSL2 dir=in action=allow protocol=TCP localport=$LPORT
}

function win_open_ports_range($lip, $lport_base, $cip, $cport_base, $len) {
    for ($i = 0; $i -lt $len ; $i++)
    {
        $lport = $lport_base + $i
        $cport = $cport_base + $i
        win_open_port $lip $lport $cip $cport
    }
}

function wsl_add_hostname_in_hostfile($HOSTIP, $HOSTNAME, $HOSTFILE) {
    wsl -u root "--%" "sed -i '/$HOSTNAME/d' $HOSTFILE"
    wsl -u root "--%" "echo $HOSTIP $HOSTNAME >> $HOSTFILE"
}

function wsl_add_hostname($HOSTIP, $HOSTNAME) {
    # --%  https://stackoverflow.com/questions/18923315/using-in-powershell
    # wsl -u root sed -i '/wslhost/d'    /etc/hosts
    # wsl -u root "--%" "echo $WSLIP      wslhost    >> /etc/hosts"
    wsl_add_hostname_in_hostfile $HOSTIP $HOSTNAME "/mnt/c/Windows/System32/drivers/etc/hosts"
    wsl_add_hostname_in_hostfile $HOSTIP $HOSTNAME "/etc/hosts"
    # wsl_add_hostname_in_hostfile("cloudhost", "/mnt/c/Windows/System32/drivers/etc/hosts")
}
##### end of functions ################
#######################################

"--------------------- Var Define -------------------------------------------"
$WSLIP           = $args[0]
$WINIP           = $args[1]
# $OPEN_PORTS_BASE = $args[2]
# $OPEN_PORTS_NUM  = $args[3]
# $REMOTEHOST      = $args[4]
# $CLOUDHOST       = $args[5]
"WSL IP = " + $WSLIP
"WIN IP = " + $WINIP

"--------------------- Local var define -------------------------------------------"
$ANY_IP          = "0.0.0.0"
$WSLPROXY        = "127.65.43.21"

"--------------------- WSL network config -------------------------------------------"
# Add an IP address in Ubuntu, $WSLIP, named eth0:1
# i.e. wsl -u root ip addr add 192.168.50.1/24 broadcast 192.168.50.255 dev eth0 label eth0:1
wsl -u root ip addr add $WSLIP/24 dev eth0 label eth0:1

# Add an IP address in Win10, $WINIP
netsh interface ip add address "vEthernet (WSL)" $WINIP 255.255.255.0

"--------------------- add port proxy in wsl2 -------------------------------------------"
"clear port proxy all "
netsh interface portproxy reset

$WSL_SSHD_PORT          = 3322     # for ssh ssh config port $WSL_SSHD_PORT - see /etc/ssh/sshd_config

# ssh
# win_open_port          $ANY_IP     $WSL_SSHD_PORT     wslhost   22            
# win_open_ports_range   $ANY_IP     $OPEN_PORTS_BASE   wslhost   $OPEN_PORTS_BASE   $OPEN_PORTS_NUM   
# for   proxy
# win_open_ports_range   wslproxy    80                 wslhost   $OPEN_PORTS_BASE   $OPEN_PORTS_NUM
# for apache - "sudo /etc/init.d/apache2 restart"
# win_open_port   wslproxy    8080               wslhost   8080
# for python httpd - "python3 -m http.server --directory /mnt/d/svn/svnwork"
# win_open_port   wslproxy    8080               wslhost   8080

"Show port proxy all "
netsh interface portproxy show all

" -------------------- Firewall ---------------------------------------- "
# for mobax xserver
# netsh advfirewall firewall add rule name=WSL2 dir=in action=allow protocol=TCP localport=6000

"add rule for wsl with winhost"
Set-NetFirewallProfile -DisabledInterfaceAliases "vEthernet (WSL)"
# New-NetFirewallRule -DisplayName "WSL" -Direction Inbound  -InterfaceAlias "vEthernet (WSL)"  -Action Allow

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

"--------------------- Modify hosts - require admin privillege ----------------------------------"
wsl_add_hostname   $WSLIP        wslhost
wsl_add_hostname   $WINIP        winhost
# wsl_add_hostname   $REMOTEHOST   remotehost
# wsl_add_hostname   $CLOUDHOST    cloudhost
# wsl_add_hostname   $WSLPROXY     wslproxy

"--------------------- Schedule Tasks ----------------------------------"
Unregister-ScheduledTask -TaskName "owen-*" -Confirm:$false

"-- for keyremap when logon --"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$action  = New-ScheduledTaskAction -Execute 'D:\.local\win10\keyremap.ahk'
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "owen-keyremap"

"-- for wsl set default user when logon --"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$action  = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-Command "Ubuntu2004 config --default-user z"'
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "owen-wsl-set-default-user" -RunLevel Highest

# "-- for shadow copy everyday --"
# $trigger = New-ScheduledTaskTrigger -Daily -At 3am
# $action  = New-ScheduledTaskAction -Execute 'wmic' -Argument 'shadowcopy call create Volume=c:\'
# Register-ScheduledTask -Action $action -Trigger $trigger -RunLevel Highest -TaskName "owen-shadowcopy" 

"Show Tasks result"
Get-ScheduledTask "owen-*"

"-------------------- wsl sshd start ------------------------"
wsl -u root /etc/init.d/ssh start

sleep 10
