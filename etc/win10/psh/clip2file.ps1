###########################################################
# Copy file from clipboard to $DesDir for win10 explorer
###########################################################

# Param(
#     [Parameter(Position = 1)][string] $DesDirPath = ".", 
#     [Parameter(Position = 2)][string] $imageName = "screenshot-{0:yyyyMMdd-HHmmss}.png" -f (Get-Date)
# )

Function GetClipboard() {
    Param(
        [Parameter(Position = 1)][string] $DesDirPath = ".", 
        [Parameter(Position = 2)][string] $imageName = "screenshot-{0:yyyyMMdd-HHmmss}.png" -f (Get-Date)
    )
    Add-Type -AssemblyName System.Windows.Forms
    # $fileDropList = new-object System.Collections.Specialized.StringCollection;

    If ([System.Windows.Forms.Clipboard]::ContainsImage()) {
        $img = get-clipboard -format image
        $imgPath = $DesDirPath + '\' + $imageName
        $img.save($imgPath)
        "Psh: Image in clipboard and saved as $imgPath"
    } ElseIf ([System.Windows.Forms.Clipboard]::ContainsFileDropList()) {
        $fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList()
        "Psh: Psh copy clipboard $($fileDropList.count) Items to DesDir " 
        "Psh: Destination Directory: "
        "Psh:     " + (Get-Item -Path $DesDirPath).FullName
        "Psh: Items: " 

        Foreach ($file in $fileDropList) {
            "Psh:     " + $file + "`t=>`t" + $DesDirPath + '\' + (Get-Item -Path $file).Name
            Copy-Item -Path $file -Destination (Get-Item -Path $DesDirPath).FullName -Recurse
        }
    } Else {
        "Psh: No appendable content was found."
    }
}

GetClipboard($args)

