###########################################################
# make shortcut for single file for win10 explorer
###########################################################

# reference:
# https://stackoverflow.com/questions/9701840/how-to-create-a-shortcut-using-powershell

# $DstFileLnkPath $SrcFilePath
#     must end with .lnk
#     must be absolute win path

param ( [string]$SrcFilePath, [string]$DstDirPath ) 

"Psh: Psh make shortcut " 
# "Psh:     " + (Get-Item -Path $SrcFilePath).FullName + ' => ' + (Get-Item -Path $DstFileLnkPath).FullName
$DstFileLnkPath = (Get-Item -Path $DstDirPath).FullName + '\' + (Get-Item -Path $SrcFilePath).Name + '.lnk'
"Psh:     " + (Get-Item -Path $SrcFilePath).FullName + ' => ' + $DstFileLnkPath

$WshShell = New-Object -comObject WScript.Shell
# destinition file
$Shortcut = $WshShell.CreateShortcut( $DstFileLnkPath )
# source file
$Shortcut.TargetPath = (Get-Item -Path $SrcFilePath).FullName  
# do make shortcut
$Shortcut.Save()

