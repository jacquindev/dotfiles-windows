<#
.SYNOPSIS
    Install VS Code Extensions
.DESCRIPTION
    This script will install all extensions that listed in 'extensions.list'.
.NOTES
    You can choose what extensions to install by edit the file 'extensions.list' first.    
#>

Set-Location $PSScriptRoot
[System.Environment]::CurrentDirectory = $PSScriptRoot

if (Get-Command code -ErrorAction SilentlyContinue) {
    $ExtensionList = Get-Content -Path "$PSScriptRoot\extensions.list"
    foreach ($extension in $ExtensionList) {
        code --install-extension $extension --force
    }
}
else {
    Write-Error "You don't have Visual Studio Code! Please install to use this script."
    Break
}
