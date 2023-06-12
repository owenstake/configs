
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
    # $xml.SelectSingleNode('/ProxifierProfile/RuleList').appendchild($newRuleNode) | Out-Null
    $xml.SelectSingleNode('/ProxifierProfile/RuleList').appendchild($newRuleNode) | Out-Null
    $ruleList = $xml.SelectSingleNode('/ProxifierProfile/RuleList')
    $ruleList.InsertAfter($newRuleNode, $ruleList.FirstChild) | Out-Null
    # $xml.ProxifierProfile.RuleList.AppendChild($newRuleNode) > $null
}

Function FileConvertCRLFtoLF($filepath) {
    $file = get-item $filepath
    [System.IO.File]::WriteAllText(
        $file.FullName,
        ([System.IO.File]::ReadAllText($file.FullName) -replace "`r`n","`n")
    )
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

Function UpdateProxifierProfile() {
    $proxifierProfileFile = "$Env:SCOOP\persist\proxifier\Profiles\Default.ppx"
    $xml = [xml](Get-Content $proxifierProfileFile -Encoding utf8)
    $configs = Get-FromJson ".\proxy.json"
    Foreach ($c in $configs.GetEnumerator()) {
        # echo asdf $c.value.Proxyip
        $id        = $c.value.Port
        $port      = $c.value.Port
        $proxyip   = $c.value.proxyIp
        $proxyinfo = $c.value.ProxyInfo
        AddProxy $xml  "$id"  "$port" 
        AddRule  $xml  "$id"  "$proxyIp"  "$proxyInfo"
    }
    $xml.Save( $proxifierProfileFile )
    & $(Get-AppExe proxifier) $proxifierProfileFile silent-load
}

UpdateProxifierProfile

# FileConvert $xmlPath

