function New-SecretVault {
    <#
    .SYNOPSIS
        Setup a SecretVault on a local machine.
    .DESCRIPTION
        This function will configure a SecretManagement modules and setup SecretVault named SecretStore on local machine.
    .LINK
        https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/how-to/using-secrets-in-automation?view=ps-modules
    #>

    #requires -Module Microsoft.PowerShell.SecretManagement
    #requires -Module Microsoft.PowerShell.SecretStore

    $userName = Read-Host "Enter your username"
    $securePasswordPath = Read-Host "Input a location to store your secrets"

    $credential = Get-Credential -UserName "$userName"
    $credential.Password | Export-Clixml -Path "$securePasswordPath"

    # Configure SecretStore vault
    Register-SecretVault -Name SecretStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault

    $mypassword = Import-Clixml -Path "$securePasswordPath"
    $storeConfiguration = @{
        Authentication  = 'Password'
        PasswordTimeout = 3600 # 1 hour
        Interaction     = 'None'
        Password        = $mypassword
        Confirm         = $false
    }
    Set-SecretStoreConfiguration @storeConfiguration
}
