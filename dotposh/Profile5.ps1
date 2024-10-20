# Environment variables
$Env:POSH_GIT_ENABLED = $true
$Env:EDITOR = "code"

# Modules
$PoshModules = @(
    "BurntToast", "posh-alias", "posh-git", "PSReadLine", "Terminal-Icons"
)
foreach ($module in $PoshModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Scope CurrentUser -Force
    }
    Import-Module -Name $module
}

# Oh-My-Posh theme configuration
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init powershell --config "$Env:POSH_THEMES_PATH\bubblesextra.omp.json" | Invoke-Expression
    oh-my-posh completion powershell | Out-String | Invoke-Expression
}

# gsudo module
if (Get-Command gsudo -ErrorAction SilentlyContinue) {
    Import-Module "$($(Get-Item $(Get-Command gsudo.exe).Path).Directory.Parent.FullName)\current\gsudoModule.psd1"
}

# scoop module
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"
}

# PSReadLine configuration
$PSROptions = @{
    BellStyle                     = "None"
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
    ExtraPromptLineCount          = $True
    HistoryNoDuplicates           = $True 
    HistorySearchCursorMovesToEnd = $True
    PredictionSource              = "History"
    PredictionViewStyle           = "ListView"
}
Set-PSReadLineOption @PSROptions

# Command definitions
# curl
if (Get-Command -Name curl.exe -ErrorAction SilentlyContinue) {
    Remove-Item Alias:curl -Force
}

# eza
if (Get-Command -Name eza.exe -ErrorAction SilentlyContinue) {
    Remove-Item Alias:eza -Force

    $_eza_params = @('--hyperlink', '--icons')

    function ls($path) { & eza.exe $_eza_params $path }
    function ll($path) { & eza.exe $_eza_params -l $path }
    function l($path) { & eza.exe $_eza_params -la $path }
}

# cat
if (Get-Command -Name bat.exe -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force
    function cat($path) { & bat.exe $path }
}

# Aliases
function which($name) { Get-Command $name | Select-Object -ExpandProperty Definition }
function mkcd($path) { New-Item -Path $path -ItemType Directory; Set-Location -Path $path }
function touch($file) { New-Item -ItemType File -Name $file -Path $PWD | Out-Null }
function ff($term) { Get-ChildItem -Recurse -Filter "*$term*" -ErrorAction SilentlyContinue | Format-Table -AutoSize }
function home { Set-Location -Path "$Env:USERPROFILE" }
function downloads { Set-Location -Path "$Env:USERPROFILE\Downloads" }
function docs { Set-Location -Path "$Env:USERPROFILE\Documents" }
function desktop { Set-Location -Path "$Env:USERPROFILE\Desktop" }