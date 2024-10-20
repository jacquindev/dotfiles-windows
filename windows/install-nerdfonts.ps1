#requires -runasadministrator

<#
.SYNOPSIS
    Install Nerd Fonts for All Users
.DESCRIPTION
    This script use 'https://to.loredo.me/Install-NerdFont.ps1' script to install nerd fonts
    Edit the list in 'fonts.list' file and then run this script to install Nerd Fonts you want.
#>

Set-Location $PSScriptRoot
[System.Environment]::CurrentDirectory = $PSScriptRoot

$NerdFonts = Get-Content -Path "$PSScriptRoot\fonts.list"
foreach ($font in $NerdFonts) {
    & ([scriptblock]::Create((Invoke-WebRequest 'https://to.loredo.me/Install-NerdFont.ps1'))) -Confirm:$false -Name $font -Scope AllUsers
}