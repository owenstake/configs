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
function win_open_port($LIP, $LPORT, $CIP, $CPORT, $REMOTEIP) {
    # "wsl portproxy for $DESCRIPTION, win port = $LPORT, sock port = $CPORT"
    # "portproxy clear" will be clear in outer
    # "portproxy add"
    netsh interface portproxy add v4tov4 listenport=$LPORT listenaddress=$LIP connectport=$CPORT connectaddress=$CIP
    # netsh interface portproxy add v4tov4 listenport=3322 listenaddress=0.0.0.0 connectport=22 connectaddress=wslhost
    # "portproxy add firewall"
    netsh advfirewall firewall add rule name=WSL2 dir=in action=allow protocol=TCP localport=$LPORT remoteip=$REMOTEIP
    # netsh advfirewall firewall add rule name=WSL2 dir=in action=allow protocol=TCP localport=3322 remoteip=192.168.89.205
    # netsh advfirewall firewall add rule name=WSL2 dir=in action=allow protocol=TCP localport=3322
}

function win_open_ports_range($lip, $lport_base, $cip, $cport_base, $len, $remoteip) {
    for ($i = 0; $i -lt $len ; $i++)
    {
        $lport = $lport_base + $i
        $cport = $cport_base + $i
        win_open_port $lip $lport $cip $cport $remoteip
    }
}

function wsl_add_hostname_in_hostfile($wslName, $hostIp, $hostName, $hostFile) {
    # --%  https://stackoverflow.com/questions/18923315/using-in-powershell
    # delete first
    wsl -d $wslName -u root "--%" "sed -i '/$hostName/d' $hostFile"
    # add host item
    wsl -d $wslName -u root "--%" "echo $hostIp $hostName >> $hostFile"
}

function wsl_add_hostname($wslName, $hostIp, $hostName) {
    wsl_add_hostname_in_hostfile $wslName $hostIp $hostName "/mnt/c/Windows/System32/drivers/etc/hosts"
    wsl_add_hostname_in_hostfile $wslName $hostIp $hostName "/etc/hosts"
}

function ExecFileAtLogOn($taskName, $file) {
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $action  = New-ScheduledTaskAction -Execute $file
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName
}

function ExecPowershellScriptAtLogOn($taskName, $script) {
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File $script"
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName
# $Action = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument '-NonInteractive -NoLogo -NoProfile -File "C:\MyScript.ps1"'
}
##### end of functions ################
#######################################

function main($WSLNAME,$WSLIP,$WINIP,$PshDir) {
    "--------------------- System Clear -----------------------------------------"
    # clear firewall rule
    netsh advfirewall firewall delete rule name=WSL2

    "--------------------- Print Args -----------------------------------------"
    # $OPEN_PORTS_BASE = $args[2]
    # $OPEN_PORTS_NUM  = $args[3]
    # $REMOTEHOST      = $args[4]
    # $CLOUDHOST       = $args[5]
    "WSL NAME = " + $WSLNAME
    "WSL IP   = " + $WSLIP
    "WIN IP   = " + $WINIP
    "PshDir   = " + $PshDir

    "--------------------- Local Define -------------------------------------------"
    $ANY_IP          = "0.0.0.0"                        # for proxy listening ip
    $OPEN_IP         = "192.168.89.205,192.168.89.206"    # allow connect to sshd
    $WSLPROXY        = "127.65.43.21"     # for wsl server port
    $WIN_SSHD_PORT   = 3322


    "--------------------- WSL network config -----------------------------------"
    # Add an IP address in Ubuntu, $WSLIP, named eth0:1
    # i.e. wsl -u root ip addr add 192.168.50.1/24 broadcast 192.168.50.255 dev eth0 label eth0:1
    # wsl -d $WSLNAME -u root ip addr add $WSLIP/24 dev eth0 label eth0:1

    # Add an IP address in Win10, $WINIP
    # netsh interface ip add address "vEthernet (WSL)" $WINIP 255.255.255.0

    "--------------------- add port proxy in wsl2 -------------------------------"
    "clear port proxy all "
    netsh interface portproxy reset

    "start ip helper for portproxy"
    net start iphlpsvc

    "SSHD open port"
    win_open_port       $ANY_IP     $WIN_SSHD_PORT      wslhost   22      $OPEN_IP
    # win_open_port       $ANY_IP     $WIN_SSHD_PORT      wslhost   22      any

    # win_open_ports_range   $ANY_IP     $OPEN_PORTS_BASE   wslhost   $OPEN_PORTS_BASE   $OPEN_PORTS_NUM   any
    # for   proxy
    # win_open_ports_range   wslproxy    80                 wslhost   $OPEN_PORTS_BASE   $OPEN_PORTS_NUM   any
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

    # "Add firewall wsl2 rules for proxy"
    # netsh advfirewall firewall add rule name=WSL2 dir=in action=allow protocol=TCP localport=10809 remoteip=$OPEN_IP

    "Add firewall wsl2 rules for icmp ping"
    # allow receive ping connection from other PC
    netsh advfirewall firewall set rule name="文件和打印机共享(回显请求 - ICMPv4-In)" new enable=yes
    # allow wsl ping win10
    # netsh advfirewall firewall set rule name="虚拟机监控(回显请求- ICMPv4-In)" new enable=yes

    # "Del firewall wsl2 rules for icmp ping"
    # netsh advfirewall firewall set rule name="文件和打印机共享(回显请求 - ICMPv4-In)" new enable=no
    # netsh advfirewall firewall set rule name="虚拟机监控(回显请求- ICMPv4-In)" new enable=no

    "Show firewall wsl2 rules"
    # https://support.microsoft.com/en-us/topic/44af15a8-72a1-e699-7290-569726b39d4a
    netsh advfirewall firewall show rule name=WSL2
    netsh advfirewall firewall show rule name="文件和打印机共享(回显请求 - ICMPv4-In)"
    # netsh advfirewall firewall show rule name="虚拟机监控(回显请求- ICMPv4-In)"

    # "TODO: start firewall "
    # netsh advfirewall set currentprofile state on

    "--------------------- Modify Hosts File - Require Admin Privillege ----------------"
    wsl_add_hostname  $wslName  $WSLIP   $wslName
    wsl_add_hostname  $wslName  $WINIP   winhost
    # wsl_add_hostname   $REMOTEHOST   remotehost
    # wsl_add_hostname   $CLOUDHOST    cloudhost
    # wsl_add_hostname   $WSLPROXY     wslproxy

    # "--------------------- Schedule Tasks ----------------------------------"
    # Unregister-ScheduledTask -TaskName "owen-*" -Confirm:$false

#     "-- For All At logon --"
#     ExecPowershellScriptAtLogOn "owen-all-entry" $PshDir"EntryAtLogOn.ps1"

#     # "-- for shadow copy everyday --"
#     # $trigger = New-ScheduledTaskTrigger -Daily -At 3am
#     # $action  = New-ScheduledTaskAction -Execute 'wmic' -Argument 'shadowcopy call create Volume=c:\'
#     # Register-ScheduledTask -Action $action -Trigger $trigger -RunLevel Highest -TaskName "owen-shadowcopy" 

#     "Show Tasks result"
#     Get-ScheduledTask "owen-*"

    "-------------------- Pause util key press ------------------------"
    cmd /c pause
}


"--------------------- Var Define -------------------------------------------"
$WSLNAME         = $args[0]
$WSLIP           = $args[1]
$WINIP           = $args[2]
$PshDir          = $args[3]

main $WSLNAME $WSLIP $WINIP $PshDir

