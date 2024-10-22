function Get-Modules {
    <#
    .SYNOPSIS
        Retrieves a list of installed PowerShell modules.

    .DESCRIPTION
        Easily manage PowerShell modules you installed by json file.

    .EXAMPLE
        > Get-Modules -output

        Output modules information into modules.lock.json file in dotfiles directory.
    .EXAMPLE
        > Get-Modules -list
        Print modules information on the console.
    #>

    [CmdletBinding()]
    param(
        [switch]$output,
        [switch]$list
    )

    if ($PSBoundParameters.Count -eq 0) {
        $result = Get-InstalledModule | Select-Object Name, Version, Author, Description | Format-Table -AutoSize
    }

    if ($output) {
        $result = Get-InstalledModule |
        Select-Object Name, Version, Author, CompanyName, Description |
        ConvertTo-Json -Depth 100 |
        Out-File "$Env:DOTFILES\modules.lock.json" -Encoding utf8
    }

    if ($list) {
        if (Test-Path "$Env:DOTFILES\modules.lock.json") {
            $result = Get-Content "$Env:DOTFILES\modules.lock.json" | ConvertFrom-Json | Format-Table -AutoSize
        }
        else {
            $result = Get-InstalledModule | Select-Object Name, Version, Author, Description | Format-Table -AutoSize
        }
    }

    return $result
}