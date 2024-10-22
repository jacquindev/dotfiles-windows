# Helper functions
# ----------------------------------------------------------------
function New-Directory {
    <#
    .SYNOPSIS
        Creates a new directory and cd into it. Alias: mkcd
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        $Path
    )
    New-Item -Path $Path -ItemType Directory
    Set-Location -Path $Path
}

function New-File {
    <#
    .SYNOPSIS
        Creates a new file with the specified name and extension. Alias: touch
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )
    New-Item -ItemType File -Name $Name -Path $PWD | Out-Null
}

function Find-File {
    <#
    .SYNOPSIS
        Finds a file in the current directory and all subdirectories. Alias: ff
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
        [string]$SearchTerm
    )
    $result = Get-ChildItem -Recurse -Filter "*$SearchTerm*" -ErrorAction SilentlyContinue
    $result | Format-Table -AutoSize
}

function Find-String {
    <#
    .SYNOPSIS
        Searches for a string in a file or directory. Alias: grep
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$SearchTerm,
        [Parameter(ValueFromPipeline, Mandatory = $false, Position = 1)]
        [string]$Directory,
        [Parameter(Mandatory = $false)]
        [switch]$Recurse
    )
    if ($Directory) {
        if ($Recurse) {
            Get-ChildItem -Recurse $Directory | Select-String $SearchTerm
            return
        }
        Get-ChildItem $Directory | Select-String $SearchTerm
        return
    }

    if ($Recurse) {
        Get-ChildItem -Recurse | Select-String $SearchTerm
        return
    }
    Get-ChildItem | Select-String $SearchTerm
}

function Remove-MyItems {
    <#
    .SYNOPSIS
        Removes an item and (optionally) all its children. Alias: rm
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$rf,
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path
    )
    Remove-Item $Path -Recurse:$rf -Force:$rf
}

function Get-Aliases {
    <#
    .SYNOPSIS
        Show information of user's defined aliases. Alias: aliases
    #>
    [CmdletBinding()]
    param()

    #requires -Module PSScriptTools
    Get-MyAlias |
    Sort-Object Source, Name |
    Format-Table -Property Name, Definition, Version, Source -AutoSize
}

function Get-CommandInfo {
    <#
    .SYNOPSIS
        Displays the definition of a command. Alias: which
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Name
    )
    Get-Command $Name | Select-Object -ExpandProperty Definition
}

# Aliases
# ----------------------------------------------------------------
Remove-Item Alias:rm -Force
# general
Set-Alias -Name 'aliases' -Value 'Get-Aliases'
Set-Alias -Name 'ff' -Value 'Find-File'
Set-Alias -Name 'grep' -Value 'Find-String'
Set-Alias -Name 'mkcd' -Value 'New-Directory'
Set-Alias -Name 'rm' -Value 'Remove-MyItems'
Set-Alias -Name 'touch' -Value 'New-File'
Set-Alias -Name 'which' -Value 'Get-CommandInfo'

#requires -Module posh-alias
# ----------------------------------------------------------------
# eza
$_eza_params = "--icons --header --hyperlink --group --git"

Add-Alias la "eza $_eza_params -al --time-style=relative --sort=modified --group-directories-first"
Add-Alias ld "eza $_eza_params -lD --show-symlinks"                     # lists only directories
Add-Alias lf "eza $_eza_params -lfa --show-symlinks"                    # lists only files (included hidden files)
Add-Alias ll "eza $_eza_params -lbhHigUmuSa --group-directories-first"  # Lists everything in details of date             
Add-Alias lt "eza $_eza_params -lT"                                     # Tree view of detailed information
Add-Alias tree "eza $_eza_params --tree"                                # Tree view

# ----------------------------------------------------------------
# common locations
Add-Alias dotf "Set-Location $env:DOTFILES"
Add-Alias dotp "Set-Location $env:DOTPOSH"
Add-Alias home "Set-Location $env:USERPROFILE"
Add-Alias docs "Set-Location $env:USERPROFILE\Documents"
Add-Alias desktop "Set-Location $env:USERPROFILE\Desktop"
Add-Alias downloads "Set-Location $env:USERPROFILE\Downloads"

# ----------------------------------------------------------------
# network
Add-Alias flushdns 'ipconfig /flushdns'
Add-Alias displaydns 'ipconfig /displaydns'

Add-Alias chrome 'Start-Process chrome'
Add-Alias edge 'Start-Process microsoft-edge:'

# ----------------------------------------------------------------
# powershell reload /restart
# Source: - https://stackoverflow.com/questions/11546069/refreshing-restarting-powershell-session-w-out-exiting
if (Test-Path -Path $PROFILE) {
    Add-Alias reload '. $PROFILE'
}
else {
    Add-Alias reload '. $PROFILE.CurrentUserAllHosts'
}
Add-Alias restart 'Get-Process -Id $PID | Select-Object -ExpandProperty Path | ForEach-Object { Invoke-Command { & "$_" } -NoNewScope }'

# ----------------------------------------------------------------
# windows system
Add-Alias sysinfo 'Get-ComputerInfo'
Add-Alias lock 'Invoke-Command { rundll32.exe user32.dll,LockWorkStation }'
Add-Alias hibernate 'shutdown.exe /h'
Add-Alias shutdown 'Stop-Computer'
Add-Alias reboot 'Restart-Computer'

Add-Alias paths '$env:PATH -Split ";"'
Add-Alias envs 'Set-Location Env:; Get-ChildItem'
Add-Alias profiles 'Get-PSProfile {$_.exists -eq "True"} | Format-List'

Add-Alias HKLM: 'Set-Location HKLM:'
Add-Alias HKCU: 'Set-Location HKCU:'