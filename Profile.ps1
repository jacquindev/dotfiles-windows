# Tls12
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Environment variables
$Env:DOTFILES = Split-Path (Get-ChildItem $PSScriptRoot | Where-Object FullName -EQ $PROFILE.CurrentUserAllHosts).Target
$Env:DOTPOSH = "$Env:DOTFILES\dotposh"
$Env:POSH_GIT_ENABLED = $True 
$Env:EDITOR = "code"

# Prompt Configuration (oh-my-posh)
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    Set-Alias -Name 'omp' -Value 'oh-my-posh'
    omp init pwsh --config "$Env:DOTPOSH\.posh-custom.omp.json" | Invoke-Expression
    # Add oh-my-posh completion
    omp completion powershell | Out-String | Invoke-Expression
}

# Alias for git (execute before import module)
Set-Alias -Name 'g' -Value 'git'

# PowerShell Modules
$PoshModules = @(
    "CompletionPredictor",
    "posh-alias",
    "posh-git",
    "PSFzf",
    "PSParseHTML",
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
    $gsudoPath = Split-Path (Get-Command gsudo.exe).Path
    Import-Module "$gsudoPath\gsudoModule.psd1"
}

# Custom functions
foreach ($file in (Get-ChildItem -Path "$Env:DOTPOSH\*\*" -Include *.ps1 -Recurse)) {
    . $file
}
Remove-Variable file

# Fastfetch
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    if ([Environment]::GetCommandLineArgs().Contains("-NonInteractive")) {
        Return
    }
    fastfetch
}