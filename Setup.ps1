<#
.SYNOPSIS
    Setup Windows machine script.
.DESCRIPTION
    This script is used to automate the setup of a Windows machine with the necessary tools and settings.
    !!Requires Developer Mode is enabled!!
#>

function Test-IsElevated {
    return (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Set working directory
Set-Location $PSScriptRoot
[System.Environment]::CurrentDirectory = $PSScriptRoot

# WinGet packages
$WingetApps = @(
    'chrisant996.Clink',
    'Docker.DockerDesktop',
    'gerardog.gsudo',
    'Git.Git',
    'GitHub.GitHubDesktop',
    'JanDeDobbeleer.OhMyPosh',
    'Microsoft.DotNet.SDK.8',
    'Microsoft.PowerShell',
    'Microsoft.PowerToys',
    'Microsoft.VisualStudioCode',
    'Ookla.Speedtest.Desktop',
    'Proton.ProtonVPN',
    #'PuTTY.PuTTY',
    'Spotify.Spotify'
)
$installedWingetApps = winget list | Out-String
foreach ($app in $WingetApps) {
    if ($installedWingetApps -notmatch $app) {
        Write-Host "Installing WinGet package $app..." -ForegroundColor 'Green'
        winget install --silent --id $app --accept-source-agreements --accept-package-agreements
    }
}

# Scoop packages (do not pollute your PATH!!)
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    ''
    Write-Host "Installing Scoop..." -ForegroundColor 'Yellow'
    if ((Test-IsElevated) -eq $false) {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
        Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
    }
    else {
        Invoke-Expression "& { $(Invoke-RestMethod -Uri 'https://get.scoop.sh') } -RunAsAdmin"
    }
}

# Scoop buckets
if (!($(scoop bucket list).Name -eq "extras")) {
    Write-Host "Adding Scoop Bucket extras..." -ForegroundColor "Green"
    scoop bucket add extras
}

$ScoopGlobalApps = @(
    '7zip', 
    'gh'
    # TODO: Add more global apps as needed here
)
foreach ($app in $ScoopGlobalApps) {
    if (!($(scoop info $app).Installed)) {
        Write-Host "Installing Scoop package $app globally..." -ForegroundColor "Green"
        if ((Test-IsElevated) -eq $False) {
            gsudo { & scoop install $app --global }
        }
        else {
            scoop install $app --global
        }
    }
}

$ScoopApps = @(
    'aria2',
    'bat',
    'eza',
    'fastfetch',
    'fd',
    'hyperfine',
    'innounp',
    'ripgrep',
    'scoop-completion',
    'speedtest-cli',
    'spicetify-cli',
    'wixtoolset',
    'wget'
)
foreach ($app in $ScoopApps) {
    if (!($(scoop info $app).Installed)) {
        Write-Host "Installing Scoop package $app..." -ForegroundColor 'Green'
        scoop install $app
    }
}

# Symlinks
$symlinks = @{
    "$env:USERPROFILE\Documents\PowerShell\profile.ps1"                                           = ".\Profile.ps1"
    "$env:USERPROFILE\Documents\PowerShell\Microsoft.VSCode_profile.ps1"                          = ".\Profile.ps1"
    "$env:USERPROFILE\Documents\WindowsPowerShell\profile.ps1"                                    = ".\dotposh\Profile5.ps1"
    "$env:USERPROFILE\.gitconfig"                                                                 = '.\home\gitconfig'
    "$env:APPDATA\Code\User\settings.json"                                                        = '.\vscode\settings.json'
    "$env:APPDATA\bat"                                                                            = ".\bat"
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = '.\windows\settings.json'
    "$env:LOCALAPPDATA\fastfetch"                                                                 = '.\fastfetch'
}
foreach ($symlink in $symlinks.GetEnumerator()) {
    Write-Host "Creating Symlink at $($symlink.Key)..." -ForegroundColor "Cyan"
    Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    New-Item -Path $symlink.Key -ItemType SymbolicLink -Target (Resolve-Path $symlink.Value) -Force | Out-Null
}

# Bat config
if (Get-Command bat -ErrorAction SilentlyContinue) {
    bat cache --clear
    bat cache --build
}

# Wsl
if (!(Get-Command wsl -ErrorAction SilentlyContinue)) {
    if ((Test-IsElevated) -eq $false) {
        gsudo { & dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart }
        gsudo { & dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart }
    }
    else {
        & dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        & dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    }

    # Download and install the Linux kernel update package
    Write-Host "Install WSL Kernel Update..." -ForegroundColor "Yellow"
    $wslUpdateInstallerUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $downloadFolderPath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
    $wslUpdateInstallerFilePath = "$downloadFolderPath/wsl_update_x64.msi"
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($wslUpdateInstallerUrl, $wslUpdateInstallerFilePath)
    Start-Process -Filepath "$wslUpdateInstallerFilePath"
}

# Setup Git
if (Test-Path -Path "$env:USERPROFILE\.gitconfig-local") {
    if ((Get-Content -Path "$env:USERPROFILE\.gitconfig-local" -Raw).Contains("[user]") -eq $False) {
        $newGitName = Read-Host "Input your Git name"
        $newGitEmail = Read-Host "Input your Git email address"
        Write-Output "[user]" >> "$env:USERPROFILE\.gitconfig-local"
        Write-Output "    name = $newGitName" >> "$env:USERPROFILE\.gitconfig-local"
        Write-Output "    email = $newGitEmail" >> "$env:USERPROFILE\.gitconfig-local"
    }
    else {
        ''
        Write-Host "Git email and name already set in local config. Skipping update." -ForegroundColor "Green"
    }
}
else {
    $newGitName = Read-Host "Input your Git name"
    $newGitEmail = Read-Host "Input your Git email address"
    New-Item -Path "$env:USERPROFILE" -Name '.gitconfig-local' -ItemType File | Out-Null
    Write-Output "[user]" >> "$env:USERPROFILE\.gitconfig-local"
    Write-Output "    name = $newGitName" >> "$env:USERPROFILE\.gitconfig-local"
    Write-Output "    email = $newGitEmail" >> "$env:USERPROFILE\.gitconfig-local"
}

''
Write-Host "All Done! Thank you for using this dotfiles repo!" -ForegroundColor "Green"