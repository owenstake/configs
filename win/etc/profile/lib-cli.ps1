
# --- scoop -------
# $scoopInfo  = scoop export | ConvertFrom-Json
# Function Update-ScoopInfoCache {
#     $scoopInfo = scoop export | ConvertFrom-Json
# }

# Function Test-AppExistsInScoopByCache($appName) {
#     If ($scoopInfo.apps | where-object -FilterScript {$PSitem -match "$appName"}) {
#         return $true
#     } else {
#         return $false
#     }
# }

# --- Alias -----------------------
Function RealPath() {
    (Get-Item @args).FullName
}

# basic alias
del alias:rp -Force
Set-Alias rp RealPath
Set-Alias wrp RealPath

# refine cd as linux bash
del alias:cd -errorAction silentlyContinue
$global:oldpwd = $global:pwd
$global:test = 'gogo'
Function cd($dir="~") {
    $tmpPath = $global:pwd
    If ($dir -eq "-") {
        cd $global:oldpwd
    } else {
        Set-Location "$dir"
    }
    If ($global:pwd -ne $tmpPath) {
        # cd success
        $global:oldpwd = $tmpPath
    }
}

# basic function
Function vic { vim ~\_vimrc }
Function psc { vim $profile }
# wt
Function wt   { wtg }
Function wtq  { $( curl "wttr.in/~quangang+quanzhou?m" ).Content | Out-Host -Paging }
Function wtg  { $( curl "wttr.in/~haizhu+guangzhou?m" ).Content | Out-Host -Paging }
## git function
del alias:gc  -errorAction silentlyContinue
del alias:glg -errorAction silentlyContinue
Function ga   {git add                  @args}
Function gd   {git diff                 @args}
Function gst  {git status               @args}
Function gc   {git commit               @args}
Function gca  {git commit -v -a         @args}
Function glg  {git log --stat           @args}
Function grbi {git rebase --interactive @args}

## jobs function
Function bg() {Start-Process -NoNewWindow @args}

del alias:rm -errorAction silentlyContinue
Function rm { Remove-Item -v @args }

# app
Function ty($pathName=".") {
    $pathName = $pathName.Trim("`"")  #
    If ( !(Test-Path $pathName )) {
        throw [System.IO.FileNotFoundException] "$pathName not found."
    }
    return typora.exe $pathName
}

# ls.exe
# If ( (Test-CommandExists fd) -and (Test-AppExistsInScoopByCache "fd") ) {
If  (Test-CommandExists "fd") {
    del alias:ls -errorAction silentlyContinue
    Function ls  {fd --max-depth 1 --strip-cwd-prefix --color always @args}
    Function la  {ls --hidden @args}
    Function ll  {ls -l @args}
    Function lla {ls -l --hidden @args}

    # Function ls  {ls.exe -h --color @args | echo }
    # Function la  {ls -a @args}
    # Function ll  {ls -l @args}
    # Function lla {ls -l -a @args}
}

# zlua init
If ( (Test-CommandExists "lua") -and (Test-Path $env:scoop\apps\z.lua\current\z.lua) ) {
    Invoke-Expression (& { (lua $env:scoop\apps\z.lua\current\z.lua --init powershell) -join "`n" })
    Function zb {z -b}
    Function zc($p) {z -c $p}
    Function zr {cd ~/Desktop }
    Function zd {cd ~/Downloads }
    Function zw {cd $env:weiyun }

    del alias:z -errorAction silentlyContinue
    Function z() {
        $tmpPath = $global:pwd
        _zlua @args
        If ($global:pwd -ne $tmpPath) {
            # cd success
            $global:oldpwd = $tmpPath
        }
    }
}

# ---------------------------
# --- PS module setting -----
# ---------------------------
# --- PSreadline -----
If (Get-Module -ListAvailable "PSreadline") {
    Import-Module PSReadLine
    set-PSReadLineOption -EditMode Emacs
    # Shows navigable menu of all options when hitting Tab
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    # Autocompletion for arrow keys
    Set-PSReadlineKeyHandler -Key Ctrl+p -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key Ctrl+n -Function HistorySearchForward
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    # auto suggestions
    Set-PSReadLineOption -PredictionSource History
}

# --- psfzf -----
If ( (Test-CommandExists "fzf") -and (Get-Module -ListAvailable "psfzf") ) {
    Import-Module psfzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSFzfOption -EnableAliasFuzzyGitStatus  # fgs
    Function gaf {
        git add $(fgs)
    }
    # $env:FZF_DEFAULT_COMMAND="fd"
    $env:FZF_CTRL_T_COMMAND="fd --color always"

    # dos => --preview '(bat --color=always {} || tre {} --directories) 2> nul'
    # psh => --preview '((bat --color=always {}) -or (tre {} --directories)) 2> $null'
    $env:FZF_CTRL_T_OPTS=$env:FZF_CTRL_T_OPTS  # defined above
    $env:FZF_CTRL_R_OPTS=$env:FZF_CTRL_R_OPTS  # defined above
}

If ( Get-Module -ListAvailable "pscolor" ) {
    $env:PSCOLORS_HIDE_DOTFILE=$true
    Import-Module PSColor   # format Get-childitem/ls result
}

# Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
# $env:FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
#
