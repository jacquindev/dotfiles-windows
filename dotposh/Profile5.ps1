# Modules
$PoshModules = @(
    "BurntToast", "posh-alias", "posh-git", "PSCompletions", "PSReadLine", "Terminal-Icons"
)
foreach ($module in $PoshModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Scope CurrentUser -Force
    }
    Import-Module -Name $module
}

# Environment variables
$Env:POSH_GIT_ENABLED = $true
$Env:EDITOR = "code"

# Oh-My-Posh theme configuration
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init powershell --config "$Env:POSH_THEMES_PATH\tokyonight_storm.omp.json" | Invoke-Expression
    oh-my-posh completion powershell | Out-String | Invoke-Expression
}

# gsudo module
if (Get-Command gsudo -ErrorAction SilentlyContinue) {
    Import-Module "$($(Get-Item $(Get-Command gsudo.exe).Path).Directory.Parent.FullName)\current\gsudoModule.psd1"
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
}
Set-PSReadLineOption @PSROptions

# Aliases
# curl
if (Get-Command -Name curl.exe -ErrorAction SilentlyContinue) { Remove-Item Alias:curl -Force }

# cat
if (Get-Command -Name bat.exe -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force
    function cat($path) { & bat.exe $path }
}

function which($name) { Get-Command $name | Select-Object -ExpandProperty Definition }
function mkcd($path) { New-Item -Path $path -ItemType Directory; Set-Location -Path $path }
function touch($file) { New-Item -ItemType File -Name $file -Path $PWD | Out-Null }
function ff($term) { Get-ChildItem -Recurse -Filter "*$term*" -ErrorAction SilentlyContinue | Format-Table -AutoSize }

# eza
if (Get-Command -Name eza.exe -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force

    $_eza_params = "--icons --header --hyperlink --group --git"
    Add-Alias ls "eza --hyperlink --icons"
    Add-Alias la "eza $_eza_params -al --time-style=relative --sort=modified --group-directories-first"
    Add-Alias ld "eza $_eza_params -lD --show-symlinks"                     # lists only directories
    Add-Alias lf "eza $_eza_params -lfa --show-symlinks"                    # lists only files (included hidden files)
    Add-Alias ll "eza $_eza_params -lbhHigUmuSa --group-directories-first"  # Lists everything in details of date             
    Add-Alias lt "eza $_eza_params -lT"                                     # Tree view of detailed information
    Add-Alias tree "eza $_eza_params --tree"                                # Tree view
} 

# common locations
Add-Alias home "Set-Location $env:USERPROFILE"
Add-Alias docs "Set-Location $env:USERPROFILE\Documents"
Add-Alias desktop "Set-Location $env:USERPROFILE\Desktop"
Add-Alias downloads "Set-Location $env:USERPROFILE\Downloads"

# powershell reload /restart
# Source: - https://stackoverflow.com/questions/11546069/refreshing-restarting-powershell-session-w-out-exiting
Add-Alias reload '. $PROFILE'
Add-Alias restart 'Get-Process -Id $PID | Select-Object -ExpandProperty Path | ForEach-Object { Invoke-Command { & "$_" } -NoNewScope }'

# Fastfetch
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    if ([Environment]::GetCommandLineArgs().Contains("-NonInteractive")) {
        Return
    }
    fastfetch
}