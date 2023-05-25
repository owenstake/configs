
echo "source lf lib file"

Function LfFormatEnvFx($str) {
    # deal lf file format
    $arr = $str -split "`n"
    $files = @()
    foreach ($a in $arr) {
        $files += $a.trim("`"")
    }
    return ,$files
}

# Format path for lf cmd cd. 
# 1. lf cmd cd need escape backslash in bash way.
Function LfFormatPath($path) {
    $path = $path -replace "\\","\\"
    return $path
}

# ===================================
# ===== Lf remote operation =========
# ===================================
# lf -remote  # execute lf cmd in script
Function LfZlua($opt, $pattern) {
    # init zlua first
    If ( !(Test-CommandExists z) -and (Test-CommandExists lua) -and (Test-Path $env:scoop\apps\z.lua\current\z.lua) ) {
        Invoke-Expression (& { (lua $env:scoop\apps\z.lua\current\z.lua --init powershell) -join "`n" })
    }

    # If(!$pattern) {
    #     echo "opt = $opt"
    #     lf -remote "send $env:id echoerr ZLUA: No args. opt is $opt"
    #     return
    # }
    # $match = z -e "$pattern"
    $prePwd = "$pwd"
    z $opt "$pattern"
    If ("$pwd" -ne "$prePwd") {
        $path = LfFormatPath $pwd
        lf -remote "send $env:id cd $path"
        lf -remote "send $env:id echo ZLUA: cd to $path"
    } else {
        lf -remote "send $env:id echoerr ZLUA: stay same dir for $pattern"
    }
    # lf -remote "send $env:id set user_zlua"
}

Function LfFzfCtrlT($pattern) {
    $env:FZF_DEFAULT_COMMAND = $env:FZF_CTRL_T_COMMAND
    $env:FZF_DEFAULT_OPTS    = $env:FZF_CTRL_T_OPTS
    $match = fzf
    If ($match) {
        $path = LfFormatPath $match
        If (Test-Path $path -PathType Container) {
            # Directory
            lf -remote "send $env:id cd $path"
            lf -remote "send $env:id echo FZF: cd to $path"
        } Else {
            # File
            vim $path
            lf -remote "send $env:id echo FZF: open $path"
        }
    } else {
        lf -remote "send $env:id echoerr FZF: No file match $pattern"
    }
    # lf -remote "send $env:id set user_fzf"
}


# Function Get-FileMimeType($file) {
#     $mimeType = file --mime-type -b $file
#     return $mimeType
# }

# Function LF-OpenFile($file) {
#     $mimeType = Get-FileMimeType($file)
#     Switch -wildcard  ($mimeType) {
#         "text/*" { vim $file }
#         default  { exp $file }
#     }
# }

