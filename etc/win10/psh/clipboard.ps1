
Function IsArray() {
	return "RemoveAt" -in $args[0].PSobject.Methods.Name
}

# flatten array to elem
Function FlattenArgs() {
    $local:flatArgs = @()
    Foreach ($arg in $local:args) {
		If (IsArray($arg)) {
			Foreach ($a in $arg) {  # path maybe wildcard like *png
				If (IsArray($a)) {
					$n = FlattenArgs($a)
					Foreach ($i in $n) {  # path maybe wildcard like *png
						$local:flatArgs += $i
					}
				} else {
					$local:flatArgs += $a
				}
			}
        } else {
			$local:flatArgs += $arg
		}
    }
    return ,$local:flatArgs
}



Function SetClipboard() {
    Add-Type -AssemblyName System.Windows.Forms
    $files = new-object System.Collections.Specialized.StringCollection

    $flatArgs = FlattenArgs($args)

    # get files from args
    Foreach ($arg in $flatArgs) {
            Foreach ($pathName in $(Get-Item -Path $arg)) {  # path maybe wildcard like *png
                [void]$files.Add($pathName)
            }
    }

    If (!$files) {
        "PSH: Nothing Copied"
        return
    }

    # add files to clipboard
    If (-not [System.Windows.Forms.Clipboard]::SetFileDropList($files)) {
        $count = $files.count
        "PSH: Copy $count items to clipboard"
        Foreach ($file in $files)
        {
            "PSH:     $file"
        }
    } else {
        "PSH: Fail SetClipboard"
    }
}

Function AppendClipboard {
    Add-Type -AssemblyName System.Windows.Forms

    # get files from clipboard
    if ([System.Windows.Forms.Clipboard]::ContainsFileDropList()) {
        $fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList()

        foreach ($file in $fileDropList) {
            $local:args += (Get-Item -Path $file).FullName
        }
    }
    SetClipboard($local:args)
}

Function ShowClipboard {
    Add-Type -AssemblyName System.Windows.Forms
    $files = new-object System.Collections.Specialized.StringCollection

    # get files from clipboard
    if ([System.Windows.Forms.Clipboard]::ContainsFileDropList()) {
        $fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList()

        foreach ($file in $fileDropList) {
            [void]$files.Add((Get-Item -Path $file).FullName)
        }
    }
    # Write-Host $files
    return $files
}

Function GetClipboard {
    Add-Type -AssemblyName System.Windows.Forms

    $flatArgs = FlattenArgs($args)
    If ($flatArgs[0]) {
        $DesDirPath = $flatArgs[0]
    } else {
        $DesDirPath = "."
    }

    If ($flatArgs[1]) {
        $imageName = $flatArgs[1]
    } else {
        $imageName = "screenshot-{0:yyyyMMdd-HHmmss}.png" -f (Get-Date)
    }
    If ([System.Windows.Forms.Clipboard]::ContainsImage()) {
        $img = get-clipboard -format image
        $fullname = $(Get-Item ${DesDirPath}).FullName
        $imgPath = "${fullname}\${imageName}"
        $img.save($imgPath)
        Write-Host "Psh: Image in clipboard and saved as $DesDirPath\$imageName"
    } ElseIf ([System.Windows.Forms.Clipboard]::ContainsFileDropList()) {
        $fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList()
        Write-Host "Psh: Psh copy clipboard $($fileDropList.count) Items to DesDir " 
        Write-Host "Psh: Destination Directory: "
        Write-Host "Psh:     $DesDirPath"
        Write-Host "Psh: Items: " 

        Foreach ($file in $fileDropList) {
            Write-Host "Psh:     $file`t=>`t$DesDirPath\$((Get-Item -Path $file).Name)"
            Copy-Item -Path $file -Destination (Get-Item -Path $DesDirPath).FullName -Recurse
        }
    } Else {
        Write-Host "Psh: No appendable content was found."
    }
}

Function MoveClipboard {
    $flatArgs = FlattenArgs($args)
    $DesDirPath = $flatArgs[0]

    $files = ShowClipboard

    "Psh: Psh Move clipboard $($files.count) Items to DesDir" 
    "Psh: Destination Directory: "
    "Psh:     $(Get-Item -Path $DesDirPath).FullName\"
    "Psh: Items: " 
    foreach ($file in $files) {
        "Psh:     Move $((Get-Item -Path $file).Name) to $DesDirPath\"
        Move-Item -Path $file -Destination (Get-Item -Path $DesDirPath).FullName
    }
}

Function Clipboard() {
    # $flatArgs = @()
    # Foreach ($arg in $local:args) {
    #     Foreach ($a in $arg) {  # path maybe wildcard like *png
    #         $flatArgs += $a
    #     }
    # }
    $flatArgs = FlattenArgs($args)
    $action   = $flatArgs[0]
    $flatArgs = $flatArgs | select -skip 1    # skip first arg
    Switch ($action) {
        {$_ -eq 'set'  } { SetClipboard       $flatArgs }
        {$_ -eq 'push' } { AppendClipboard    $flatArgs }
        {$_ -eq 'show' } { ShowClipboard      $flatArgs }
        {$_ -eq 'get'  } { GetClipboard       $flatArgs }
        {$_ -eq 'move' } { MoveClipboard      $flatArgs }
        {$_ -eq 'test' } { echo "args is"     $local:args }
        Default          { echo "unknow action $action"  }
    }
}

If ($MyInvocation.InvocationName -match $MyInvocation.MyCommand.Name) {
	# echo "we are exec this script"
    Clipboard $script:args
} else {
	# echo "we are source this script"
}
