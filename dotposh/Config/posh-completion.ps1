# Azure PowerShell
# For more information, please see:
# - https://learn.microsoft.com/en-us/powershell/azure/az-predictor
if (Get-Module -ListAvailable -Name Az) {
    if (-not (Get-Module -ListAvailable -Name Az.Tools.Predictor)) {
        Write-Host "Installing PowerShell Module Az.Tools.Predictor..." -ForegroundColor "Green"
        Install-Module -Name Az.Tools.Predictor -Scope CurrentUser -Force
    }
    Import-Module Az.Tools.Predictor
}

# winget
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# dotnet
if (Get-Command dotnet -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# scoop
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    if (-not (Get-Module -ListAvailable -Name scoop-completion)) {
        Write-Host "Installing scoop-completion..." -ForegroundColor "Green"
        scoop bucket add extras
        scoop install scoop-completion
    }
    Import-Module scoop-completion
}

# npm
if (Get-Command npm -ErrorAction SilentlyContinue) {
    if (-not (Get-Module -ListAvailable -Name npm-completion)) {
        Write-Host "Installing PowerShell Module npm-completion..." -ForegroundColor "Green"
        Install-Module npm-completion -Scope CurrentUser -Force
    }
    Import-Module npm-completion
}

# docker
if (Get-Command docker -ErrorAction SilentlyContinue) {
    if (-not (Get-Module -ListAvailable -Name DockerCompletion)) {
        Write-Host "Installing PowerShell Module DockerCompletion..." -ForegroundColor "Green"
        Install-Module DockerCompletion -Scope CurrentUser -Force
    }
    Set-Alias -Name 'd' -Value 'docker'
    Import-Module DockerCompletion
}

# kubectl
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    kubectl completion powershell | Out-String | Invoke-Expression
    Set-Alias -Name 'k' -Value 'kubectl'
    Register-ArgumentCompleter -CommandName k -ScriptBlock $__kubectlCompleterBlock
    
    if (Test-Path -Path "$Env:DOTPOSH\Config\kubectl-aliases-powershell\kubectl_aliases.ps1") {
        . "$Env:DOTPOSH\Config\kubectl-aliases-powershell\kubectl_aliases.ps1"
    }
}
