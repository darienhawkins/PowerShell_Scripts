<##############################################################################

Date Created:       02 Jun 2021
Date Modified:      02 Jun 2021
                    20210702
Version:            1.0.0
Author:             Darien Hawkins (darien-hawkins@hotmail.com)
Descripton:         To generate a strong password with numbers, letters, 
                    mix of upper and lower case characters,
                    adn special characters

###############  Update History  ##############################################
    Date    |  ver  |  Notes
------------|-------|----------------------------------------------------------
02 Jun 2021 | 1.0.0 | Initial draft
------------|-----  |----------------------------------------------------------
##############################################################################>

function GenerateStrongRandomPassword
{
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [int]$PasswordLength,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [int]$NumberOfSpecialCharacters
    )
    Process
    {
        $psMajorVersionNumber=(Get-Host).version.major
        if ($psMajorVersionNumber -ne "5")
        {
            $noGoVersion=Get-Host |Select-Object version
            Write-Host "This function only works with the Windows only WMF Powershell."
            Write-Host "You are running $noGoVersion"
            break
        }
        # Import System.Web assembly. Only works with WMF/.NET Framework PowerShell (5.1.xxxx)
        Add-Type -AssemblyName System.Web
        $strongClearPass=[System.Web.Security.Membership]::GeneratePassword($PasswordLength,$NumberOfSpecialCharacters)
        # $global:rndmPass=ConvertTo-SecureString -AsPlainText $strongClearPass -Force
        # $clear-host
        Set-Clipboard -Value $strongClearPass
        Write-Host "Strong password:  $strongClearPass " -ErrorAction SilentlyContinue
        write-Host "Password copied to clipboard." -ErrorAction SilentlyContinue
    }
}