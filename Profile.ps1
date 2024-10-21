# Tls12
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# PowerShell Modules
$PoshModules = @(
    "BurntToast",
    "CompletionPredictor",
    "posh-alias",
    "posh-git",
    "PSFzf",
    "PSParseHTML",
    "PSProfiler",
    "PSScriptTools",
    "PSWebSearch",
    "Terminal-Icons",
    "Microsoft.PowerShell.SecretManagement",
    "Microsoft.PowerShell.SecretStore"
)
foreach ($module in $PoshModules) {
    if (!(Get-InstalledModule -Name $module -ErrorAction SilentlyContinue)) {
        Write-Host "Installing PowerShell Module $module..." -ForegroundColor "Green"
        Install-Module $module -Force -AcceptLicense -Scope CurrentUser
    }
    Import-Module $module -WarningAction SilentlyContinue
}
Remove-Variable module, PoshModules

# gsudo module
if (Get-Command gsudo -ErrorAction SilentlyContinue) {
    Import-Module "$($(Get-Item $(Get-Command gsudo.exe).Path).Directory.Parent.FullName)\current\gsudoModule.psd1"
}

# Helper function to find dotfiles location
function Find-DotfilesRepo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$ProfilePath
    )

    # Resolve the symbolic link of the profile
    $profileSymlink = Get-ChildItem $ProfilePath | Where-Object FullName -EQ $PROFILE
    return Split-Path $profileSymlink.Target
}

# Environment Variables
$Env:DOTFILES = Find-DotfilesRepo -ProfilePath $PSScriptRoot
$Env:DOTPOSH = "$Env:DOTFILES\dotposh"
$Env:POSH_GIT_ENABLED = $True
$Env:EDITOR = "code"

# Prompt Configuration (oh-my-posh)
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$Env:DOTPOSH\.posh-custom.omp.json" | Invoke-Expression
    # Add oh-my-posh completion
    oh-my-posh completion powershell | Out-String | Invoke-Expression
}

# Custom functions
foreach ($file in (Get-ChildItem -Path "$Env:DOTPOSH\*\*" -Include *.ps1 -Recurse)) {
    . $file
}

# Fastfetch
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    if ([Environment]::GetCommandLineArgs().Contains("-NonInteractive")) {
        Return
    }
    fastfetch
}