
Add-Type -AssemblyName System.Windows.Forms  # Introduce .net clipboard

Function IsArray() {
	return "RemoveAt" -in $args[0].PSobject.Methods.Name
}

# flatten array to elem
# Function FlattenArgs() {
#     $fargs = @()
#     Foreach ($arg in $args) {
# 		If (IsArray($arg)) {
# 			Foreach ($a in $arg) {  # path maybe wildcard like *png
# 				If (IsArray $a ) {
# 					$n = FlattenArgs @a 
# 					Foreach ($i in $n) {  # path maybe wildcard like *png
# 						$fargs += $i
# 					}
# 				} else {
# 					$fargs += $a
# 				}
# 			}
#         } else {
# 			$fargs += $arg
# 		}
#     }
#     return ,$fargs
# }

Function SetClipboard() {
    $files = new-object System.Collections.Specialized.StringCollection
    # get files from args
    Foreach ($arg in $args) {
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
    # get files from clipboard
    if ([System.Windows.Forms.Clipboard]::ContainsFileDropList()) {
        $fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList()

        foreach ($file in $fileDropList) {
            $args += (Get-Item -Path $file).FullName
        }
    }
    SetClipboard($args)
}

Function ShowClipboard {
    $files = new-object System.Collections.Specialized.StringCollection

    # get files from clipboard
    if ([System.Windows.Forms.Clipboard]::ContainsFileDropList()) {
        $fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList()
        foreach ($file in $fileDropList) {
            [void]$files.Add((Get-Item -Path $file).FullName)
        }
    }
    return $files
}

Function GetClipboard($DesDirPath, $ImageName)
{
    # default args value do not take effect because of @args
    If ($args[0]) {
        $DesDirPath = $args[0]
    } else {
        $DesDirPath = "."
    }

    If ($args[1]) {
        $ImageName = $args[1]
    } else {
        $ImageName = "screenshot-{0:yyyyMMdd-HHmmss}.png" -f (Get-Date)
    }

    If ([System.Windows.Forms.Clipboard]::ContainsImage()) {
        $img = get-clipboard -format image
        $fullname = $(Get-Item ${DesDirPath}).FullName
        $imgPath = "${fullname}\${ImageName}"
        $img.save($imgPath)
        Write-Host "Psh: Image in clipboard and saved as $DesDirPath\$ImageName"
    } ElseIf ([System.Windows.Forms.Clipboard]::ContainsFileDropList()) {
        $fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList()
        Write-Host "Psh: Psh copy clipboard $($fileDropList.count) Items to DesDir " 
        Write-Host "Psh: Destination Directory: "
        Write-Host "Psh:     $DesDirPath"
        Write-Host "Psh: Items: " 

        Foreach ($file in $fileDropList) {
            Write-Host "Psh:     $file`t=>`t$DesDirPath\$((Get-Item -Path $file).Name)"
            Copy-Item -Recurse -Path $file -Destination (Get-Item -Path $DesDirPath).FullName
        }
    } Else {
        Write-Host "Psh: No appendable content was found."
    }
}

Function MoveClipboard {
    $DesDirPath = $args[0]

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

Function Clipboard {
    $action = $args[0]
    $newArgs  = $args | select -skip 1    # shift args
    Switch ($action) {
        {$_ -eq 'set'  } { SetClipboard        $newArgs }  # use $fargs, not @fargs. fargs is already flatten, do no need @args to flatten again.
        {$_ -eq 'push' } { AppendClipboard     $newArgs }
        {$_ -eq 'show' } { ShowClipboard       $newArgs }
        {$_ -eq 'get'  } { GetClipboard        $newArgs }
        {$_ -eq 'move' } { MoveClipboard       $newArgs }
        {$_ -eq 'test' } { echo "args is"      $args }
        Default          { echo "unknow action $action"  }
    }
}

If ($MyInvocation.InvocationName -match $MyInvocation.MyCommand.Name) {
	# echo "we are exec this script"
    Clipboard @script:args
} else {
	# echo "we are source this script"
}
