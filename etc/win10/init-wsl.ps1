###########################################################
# Init WSL IP and Forward in win10
# we must config this script as a start script in win10 as D:/.local/win10/init-wsl.ps1
###########################################################

# Run ps1 as ADMIN
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}


$WSLIP=$args[0]
$WINHOSTIP=$args[1]

# Add an IP address in Ubuntu, $WSLIP, named eth0:1
# i.e. wsl -u root ip addr add 192.168.50.1/24 broadcast 192.168.50.255 dev eth0 label eth0:1
wsl -u root ip addr add $WSLIP/24 dev eth0 label eth0:1

# Add an IP address in Win10, $WINHOSTIP
netsh interface ip add address "vEthernet (WSL)" $WINHOSTIP 255.255.255.0

# Add forward rule table for ssh port 2222. ssh config port 2222 - see /etc/ssh/sshd_config
netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=2222 connectaddress=wslhost

# Modify hosts - this require admin privillege
wsl --% sed -i '/wslhost/d' /mnt/c/Windows/System32/drivers/etc/hosts
wsl --% echo "$WSLIP wslhost" >> /mnt/c/Windows/System32/drivers/etc/hosts

# sshd start
wsl -u root /etc/init.d/ssh start
