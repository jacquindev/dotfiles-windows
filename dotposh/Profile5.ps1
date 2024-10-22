<#
.SYNOPSIS
    Windows PowerShell profile.
.DESCRIPTION
    This profile file used for Windows PowerShell only.
    Since some modules are not compatible with PowerShell Core, I have to setup a separated profile for Windows PowerShell.
.EXAMPLE
    Open a new PowerShell console with this profile loaded.
#>

# Environment variables
$Env:DOTPOSH = Split-Path (Get-ChildItem $PSScriptRoot | Where-Object FullName -EQ $PROFILE).Target
$Env:POSH_GIT_ENABLED = $True 
$Env:EDITOR = "code"

# Oh-my-posh prompt
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    Set-Alias -Name 'omp' -Value 'oh-my-posh'
    omp init powershell --config "$Env:POSH_THEMES_PATH\tokyonight_storm.omp.json" | Invoke-Expression
    omp completion powershell | Out-String | Invoke-Expression
}

# Alias for git (execute before import module)
Set-Alias -Name 'g' -Value 'git'

# Modules
$PoshModules = @(
    "BurntToast", "posh-alias", "posh-git", "PSScriptTools", "PSReadLine", "PSWebSearch", "Terminal-Icons"
)
foreach ($module in $PoshModules) {
    if (!(Get-InstalledModule -Name $module -ErrorAction SilentlyContinue)) {
        Write-Host "Installing PowerShell module: $module ..." -ForegroundColor "Cyan"
        Install-Module $module -Force -AcceptLicense -Scope CurrentUser
    }
    Import-Module $module -WarningAction SilentlyContinue
}
Remove-Variable module, PoshModules

# gsudo module
if (Get-Command gsudo -ErrorAction SilentlyContinue) {
    $gsudoPath = Split-Path (Get-Command gsudo.exe).Path
    Import-Module "$gsudoPath\gsudoModule.psd1"
}

# More aliases
if (Test-Path "$Env:DOTPOSH\Config\posh-aliases.ps1") {
    . "$Env:DOTPOSH\Config\posh-aliases.ps1"
}

# PSReadline configuration
$PSROptions = @{
    Colors                        = @{
        "Command"   = [ConsoleColor]::Green
        "Parameter" = [ConsoleColor]::Gray
        "Operator"  = [ConsoleColor]::Magenta
        "Variable"  = [ConsoleColor]::White
        "String"    = [ConsoleColor]::Yellow
        "Number"    = [ConsoleColor]::Blue
        "Type"      = [ConsoleColor]::Cyan
        "Comment"   = [ConsoleColor]::DarkCyan
    }
    BellStyle                     = "None"
    ExtraPromptLineCount          = $True
    HistoryNoDuplicates           = $True
    HistorySearchCursorMovesToEnd = $True
    MaximumHistoryCount           = 4096
    PredictionSource              = "History"
    PredictionViewStyle           = "ListView"
}
Set-PSReadLineOption @PSROptions