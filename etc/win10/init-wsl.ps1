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
function wsl_add_proxy($DESCRIPTION, $WIN_IP, $WIN_PORT, $WSL_HOST, $WSL_PORT) {
    "wsl portproxy for $DESCRIPTION, win port = $WIN_PORT, sock port = $WSL_PORT"
    # "portproxy clear"
    # netsh interface portproxy delete v4tov4 listenport=$WIN_PORT listenaddress=$WIN_IP
    # "portproxy add"
    netsh interface portproxy add v4tov4 listenport=$WIN_PORT listenaddress=$WIN_IP connectport=$WSL_PORT connectaddress=$WSL_HOST
    # "portproxy add firewall"
    netsh advfirewall firewall add rule name=WSL2 dir=in action=allow protocol=TCP localport=$WIN_PORT
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

"--------------------- var define -------------------------------------------"
$WSLIP=$args[0] 
$WINIP=$args[1] 
$REMOTEHOST=$args[2] 
$CLOUDHOST=$args[3] 
$ANY_IP="0.0.0.0"
$WSLPROXY="127.65.43.21"
"WSL IP = " + $WSLIP
"WIN IP = " + $WINIP
##### end of var define #################

"--------------------- wsl network config -------------------------------------------"
# Add an IP address in Ubuntu, $WSLIP, named eth0:1
# i.e. wsl -u root ip addr add 192.168.50.1/24 broadcast 192.168.50.255 dev eth0 label eth0:1
wsl -u root ip addr add $WSLIP/24 dev eth0 label eth0:1

# Add an IP address in Win10, $WINIP
netsh interface ip add address "vEthernet (WSL)" $WINIP 255.255.255.0

"--------------------- add port proxy in wsl2 -------------------------------------------"
"reset port proxy all "
netsh interface portproxy reset

# ssh config port $WSL_SSHD_PORT - see /etc/ssh/sshd_config
$WSL_SSHD_PORT="3322"          # for ssh
$PROXY_HTTP_PORT="38080"
$PROXY_SOCK_PORT="38081"

wsl_add_proxy   "ssh"                 $ANY_IP      "3322"             wslhost   "22"
wsl_add_proxy   "goproxy for http"    $ANY_IP      $PROXY_SOCK_PORT   wslhost   $PROXY_SOCK_PORT
wsl_add_proxy   "wsl port for http"   "wslproxy"   "80"               wslhost   $PROXY_HTTP_PORT  # wslproxy:80 <=> wslhost:38080

"Show port proxy all "
netsh interface portproxy show all

" -------------------- Firewall ---------------------------------------- "
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

"--------------------- Modify hosts - require admin privillege ----------------------------------"
wsl_add_hostname   $WSLIP        "wslhost"
wsl_add_hostname   $REMOTEHOST   "remotehost"
wsl_add_hostname   $CLOUDHOST    "cloudhost"
wsl_add_hostname   $WSLPROXY     "wslproxy"

"-------------------- sshd start ------------------------"
wsl -u root /etc/init.d/ssh start

sleep 10
