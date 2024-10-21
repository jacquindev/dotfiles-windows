<#
.SYNOPSIS
    Setup dotfiles repos and install applications
.DESCRIPTION
    !! This script requires running on 'Developer Mode' !!
    For more information, please check the link below:
        - https://learn.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development
#>

$symlinks = @{
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"                      = ".\Profile.ps1"
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.VSCode_profile.ps1"                          = ".\Profile.ps1"
    "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"               = ".\dotposh\Profile5.ps1"
    "$env:USERPROFILE\.gitconfig"                                                                 = '.\home\gitconfig'
    "$env:USERPROFILE\.gitconfig_local"                                                           = '.\home\gitconfig_local'
    "$env:APPDATA\Code\User\settings.json"                                                        = '.\vscode\settings.json'
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = '.\windows\settings.json'
    "$env:LOCALAPPDATA\fastfetch"                                                                 = '.\fastfetch'
}

# Set working directory
Set-Location $PSScriptRoot
[System.Environment]::CurrentDirectory = $PSScriptRoot

# WinGet packages
$WingetApps = @(
    'chrisant996.Clink',
    'Git.Git',
    'GitHub.GitHubDesktop',
    'JanDeDobbeleer.OhMyPosh',
    'Microsoft.PowerShell',
    'Microsoft.PowerToys',
    'Microsoft.VisualStudioCode',
    'Ookla.Speedtest.Desktop',
    'Proton.ProtonVPN',
    'Spotify.Spotify'
)
$installedWingetApps = winget list | Out-String
foreach ($app in $WingetApps) {
    if ($installedWingetApps -notmatch $app) {
        Write-Host "Installing WinGet package $app..." -ForegroundColor 'Green'
        winget install --silent --id $app --accept-source-agreements --accept-package-agreements
    }
}

# Scoop packages (do not pollute your home!!)
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host 'Installing Scoop...' -ForegroundColor 'Green'
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    scoop bucket add extras
}
$ScoopApps = @(
    'aria2',
    'bat',
    'eza',
    'fastfetch',
    'fd',
    'gsudo',
    'hyperfine',
    'innounp',
    'ripgrep',
    'scoop-completion',
    'speedtest-cli',
    'spicetify-cli',
    'wixtoolset'
)
foreach ($app in $ScoopApps) {
    if (!($(scoop info $app).Installed)) {
        Write-Host "Installing Scoop package $app..." -ForegroundColor 'Green'
        scoop install $app
    }
}

$ScoopGlobalApps = @('7zip', 'openssh')
foreach ($app in $ScoopGlobalApps) {
    if (!($(scoop info $app).Installed)) {
        Write-Host "Installing Scoop package $app globally..." -ForegroundColor 'Green'
        sudo scoop install $app --global
    }
}

# Create Symbolic Links
Write-Host 'Creating Symbolic Links' -ForegroundColor 'Yellow'
foreach ($symlink in $symlinks.GetEnumerator()) {
    Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    New-Item -Path $symlink.Key -ItemType SymbolicLink -Target (Resolve-Path $symlink.Value) -Force | Out-Null
}
Write-Host 'All Done!' -ForegroundColor 'Green'
