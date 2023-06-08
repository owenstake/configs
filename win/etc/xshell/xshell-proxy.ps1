
######## Function ###################
# [Use PowerShell to Work with Any INI File - Scripting Blog](https://devblogs.microsoft.com/scripting/use-powershell-to-work-with-any-ini-file/ )
Function Get-IniContent ($filePath) {
    $ini = @{}
    switch -regex -file $FilePath
    {
        "^\[(.+)\]" # Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        "^(;.*)$" # Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = 'Comment' + $CommentCount
            $ini[$section][$name] = $value
        }
        "(.+?)\s*=(.*)" # Key
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}

Function Get-IniContentToString($InputObject) {
    $lines = @()
    Foreach ($i in $InputObject.keys) {
        if (!($($InputObject[$i].GetType().Name) -eq "Hashtable")) {
            #No Sections
            $lines += "$i=$($InputObject[$i])"
        } else {
            #Sections
            $lines += "[$i]"
            Foreach ($j in ($InputObject[$i].keys | Sort-Object)) {
                if ($j -match "^Comment[\d]+") {
                    $lines += "$($InputObject[$i][$j])"
                } else {
                    $lines += "$j=$($InputObject[$i][$j])"
                }
            }
            $lines += ""
        }
    }
    return $lines
    # return $lines -join "`n"
}

# [powershell - Create Hashtable from JSON - Stack Overflow](https://stackoverflow.com/questions/40495248/create-hashtable-from-json )
[CmdletBinding]
Function Get-FromJson {
    param(
        [Parameter(Mandatory=$true, Position=1)]
        [string]$Path
    )
    Function Get-Value {
        param( $value )
        $result = $null
        if ( $value -is [System.Management.Automation.PSCustomObject] ) {
            Write-Verbose "Get-Value: value is PSCustomObject"
            $result = @{}
            $value.psobject.properties | ForEach-Object { 
                $result[$_.Name] = Get-Value -value $_.Value 
            }
        } elseif ($value -is [System.Object[]]) {
            $list = New-Object System.Collections.ArrayList
            Write-Verbose "Get-Value: value is Array"
            $value | ForEach-Object {
                $list.Add((Get-Value -value $_)) | Out-Null
            }
            $result = $list
        } else {
            Write-Verbose "Get-Value: value is type: $($value.GetType())"
            $result = $value
        }
        return $result
    }

    if (Test-Path $Path) {
        $json = Get-Content $Path -Raw -Encoding utf8   # "-Encoding utf8" is important for chinease char
    } else {
        $json = '{}'
    }
    $hashtable = Get-Value -value (ConvertFrom-Json $json)
    return $hashtable
}

Function Main() {
    # ---- Config info ------------
    $mapServerIpToDynamicTunnelPort = Get-FromJson ".\proxy.json"

    Write-Output "====== Map serverIp to port ==================="
    $mapServerIpToDynamicTunnelPort | ConvertTo-Json
    # $mapServerIpToDynamicTunnelPort["10.12.44.3"]

    # ---- Var define -------------
    $XshellExe  = "C:\Program Files (x86)\NetSarang\Xshell 7\Xshell.exe"
    $ConfigFile = $script:args[0]
    $serverIp   = $ConfigFile -replace ".*\((\d.*)\)\.xsh","`$1"  # get serverIp from file name

    If (!($mapServerIpToDynamicTunnelPort[$serverIp]) -or 
            !($dynamicTunnelPort = $mapServerIpToDynamicTunnelPort[$serverIp]["Port"])) {
        Write-Error "No dynamic port for $serverIp. Just Run Xshell"
        Read-Host -Prompt "Press {enter} to continue"
        & "$XshellExe" "$ConfigFile"
        exit
    }

    $iniNeedItems = @{
        'CONNECTION:SSH' = @{
            'FwdReq_0_LocalOnly'   = 0                     
            'FwdReq_0_Incoming'    = 2                     
            'FwdReq_0_Port'        = "$dynamicTunnelPort"  
            'FwdReq_0_HostPort'    = 0                     
            'FwdReqCount'          = 1                    
            # 'FwdReq_0_Host'        = $null                 
            # 'FwdReq_0_Description' = $null                 
            # 'FwdReq_0_Source'      = $null                 
            }
        'CONNECTION:AUTHENTICATION' = @{
            'ExpectSend_Expect_0' = "~]$"
            'ExpectSend_Send_0'   = "TMOUT=0"
            'ExpectSend_Count'    = 1
            'UseExpectSend'       = 1
            }
        }

    "===== Variable Print ======================"
    Write-Output "Script Args are $script:args" 
    Write-Output "Xshell ConfigFile is $ConfigFile `nserverIp is $serverIp `ndynamicTunnelPort is $dynamicTunnelPort"

    "===== Parse Xshell Ini file ======================"
    $ini = Get-IniContent $ConfigFile

    "===== Modify Xshell Ini content ======================"
    $iniNeedItems.GetEnumerator() | ForEach-Object {
        $section = $_.Key
        $_.Value.GetEnumerator() | ForEach-Object {
            $ini[$section][$_.Key] = $_.Value
        }
    }

    "===== Write to Ini file ======================"
    Get-IniContentToString $ini | Set-Content $ConfigFile

    "===== Checking final config in xsh ====>"
    Read-Host -Prompt "Press {enter} key to continue"

    "===== Start Xshell ============="
    & "$XshellExe" "$ConfigFile"
    "===== Start Proxifier ============="


}

Main

