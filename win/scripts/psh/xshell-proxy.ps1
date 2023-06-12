
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

Function AddProxy($xml, $proxyId, $port) {
    # echo "$proxyId"  "$port" 
    # duplicat node detect
    Foreach ($n in $xml.ProxifierProfile.ProxyList.ChildNodes) {
        if ($proxyId -eq $n.id) {
            echo "Remove duplicate proxy id $proxyid"
            $n.ParentNode.RemoveChild($n) > $null
        }
    }

    $newProxyNode = [xml]@"
    <Proxy id="$proxyId" type="SOCKS5">
      <Options>48</Options>
      <Port>$port</Port>
      <Address>127.0.0.1</Address>
    </Proxy>
"@
    $newProxyNode = $xml.ImportNode($newProxyNode.Proxy,$true)
    $xml.SelectSingleNode('/ProxifierProfile/ProxyList').appendchild($newProxyNode) | Out-Null
    # $xml.ProxifierProfile.ProxyList.AppendChild($newProxyNode) > $null
}

Function AddRule($xml, $proxyId, $proxyIp, $name) {
    Foreach ($n in $xml.ProxifierProfile.RuleList.ChildNodes) {
        if ($proxyId -eq $n.action.innerXml) {
            echo "Remove duplicate proxy rule id $proxyid"
            $n.ParentNode.RemoveChild($n) > $null
        }
    }
    $newRuleNode = [xml]@"
    <Rule enabled="true">
      <Action type="Proxy">$proxyId</Action>
      <Targets>$proxyIp</Targets>
      <Name>$name</Name>
    </Rule>
"@
    $newRuleNode = $xml.ImportNode($newRuleNode.Rule,$true)
    $xml.SelectSingleNode('/ProxifierProfile/RuleList').appendchild($newRuleNode) | Out-Null
    $ruleList = $xml.SelectSingleNode('/ProxifierProfile/RuleList')
    $ruleList.InsertAfter($newRuleNode, $ruleList.FirstChild) | Out-Null
}

Function UpdateProxifier($config) {
    $proxifierProfileFile = "$Env:SCOOP\persist\proxifier\Profiles\Default.ppx"
    $xml = [xml](Get-Content $proxifierProfileFile -Encoding utf8)

    $id        = $config["Port"]
    $port      = $config["Port"]
    $proxyip   = $config["proxyIp"]
    $proxyinfo = $config["ProxyInfo"]
    AddProxy  $xml  "$id"  "$port" 
    AddRule   $xml  "$id"  "$proxyIp"  "$proxyInfo"
    $xml.Save($proxifierProfileFile)

    & "$Env:SCOOP/apps/proxifier/current/Proxifier.exe" $proxifierProfileFile silent-load
}

Function UpdateXshell($config, $XshellconfigFile) {
    $XshellExe  = "C:\Program Files (x86)\NetSarang\Xshell 7\Xshell.exe"
    $iniNeedItems = @{
        'CONNECTION:SSH' = @{
            'FwdReq_0_LocalOnly'   = 0                     
            'FwdReq_0_Incoming'    = 2                     
            'FwdReq_0_Port'        = "$dynamicTunnelPort"  
            'FwdReq_0_HostPort'    = 0                     
            'FwdReqCount'          = 1                    
        }
        'CONNECTION:AUTHENTICATION' = @{
            'ExpectSend_Expect_0'   = "~]$"
            'ExpectSend_Send_0'     = "TMOUT=0"
            'ExpectSend_Count'      = 1
            'UseExpectSend'         = 1
        }
    }

    "===== Variable Print ======================"
    Write-Output "Script Args are $script:args" 
    Write-Output "Xshell ConfigFile is $XshellconfigFile `nserverIp is $serverIp `ndynamicTunnelPort is $dynamicTunnelPort"

    "===== Parse Xshell Ini file ======================"
    $ini = Get-IniContent $XshellconfigFile

    "===== Modify Xshell Ini content ======================"
    $iniNeedItems.GetEnumerator() | ForEach-Object {
        $section = $_.Key
        $_.Value.GetEnumerator() | ForEach-Object {
            $ini[$section][$_.Key] = $_.Value
        }
    }

    "===== Write to Ini file ======================"
    Get-IniContentToString $ini | Set-Content $XshellconfigFile

    "===== Start Xshell ============="
    & "$XshellExe" "$XshellconfigFile"

}

Function Main() {
    " ---- Get Config info ------------"
    If (Test-Path "./proxy.json") {
        $configsFile = ".\proxy.json"
    } elseif (Test-Path "$env:OwenInstallDir/etc/common/proxy.json") {
        $configsFile = "$env:OwenInstallDir/etc/common/proxy.json"
    } else {
        Write-Error "No found proxy.json. Exiting"
        exit
    }
    "Found proxy.json in $configsFile"
    # $configsFile = "$env:OwenInstallDir/etc/common"
    $configs     = Get-FromJson "$configsFile"
    $XshellExe   = "C:\Program Files (x86)\NetSarang\Xshell 7\Xshell.exe"

    # "====== Map serverIp to port ==================="
    # $configs | ConvertTo-Json

    # ---- Var define -------------
    $XshellConfigFile = $script:args[0]
    $serverIp   = $XshellConfigFile -replace ".*\((\d.*)\)\.xsh","`$1"  # get serverIp from file name

    If (!($curConfig = $configs[$serverIp]) -or 
            !($dynamicTunnelPort = $curConfig["Port"])) {
        Write-Error "No dynamic port for $serverIp. Just Run Xshell"
        # Read-Host -Prompt "Press {enter} to continue"
        cmd /c pause
        & "$XshellExe" "$XshellConfigFile"
        exit
    }

    "===== Start Xshell ============="
    UpdateXshell $curConfig $XshellConfigFile

    "===== Start Proxifier ============="
    UpdateProxifier $curConfig
    cmd /c pause
}

Main

