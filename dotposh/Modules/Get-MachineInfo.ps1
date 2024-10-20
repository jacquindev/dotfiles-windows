function Get-MachineInfo {
    [CmdletBinding()]
    param (
        [switch]$graphic,
        [switch]$bios,
        [switch]$process
    )
    if ($graphic) {
        Get-WmiObject Win32_videocontroller |
        Select-Object Caption, Current*Resolution, *RefreshRate, Status |
        Format-List
    }

    if ($bios) {
        Get-WmiObject -Class Win32_Bios
    }

    if ($process) {
        Get-WmiObject win32_process |
        Select-Object ProcessName, ProcessID, CommandLine, ThreadCount |
        Sort-Object ThreadCount |
        Format-Table -GroupBy ProcessName -AutoSize
    }
}

function Invoke-MachineInfo-Graphic {
    Get-MachineInfo -graphic
}

function Invoke-MachineInfo-Bios {
    Get-MachineInfo -bios
}

function Invoke-MachineInfo-Process {
    Get-MachineInfo -process
}

Set-Alias -Name 'graphic-info' -Value 'Invoke-MachineInfo-Graphic'
Set-Alias -Name 'bios-info' -Value 'Invoke-MachineInfo-Bios'
Set-Alias -Name 'process-info' -Value 'Invoke-MachineInfo-Process'