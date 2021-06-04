# Important information obfuscated (hostname, IP address, username, password, etc)

<#
###############################################################################

  Date Created:  29 Mar 2021
  Date Modified: 02 Apr 2021
  Version: 0.3
  Authored By: Darien Hawkins (Director, Computer Center)
  Purpose: To programtically disable and expire accounts

###############  Update History  ###############

   Date     | Seq |  Action
------------|-----|------------------------------------------------------------
29 Mar 2021 | 001 | Initial draft
------------|-----|------------------------------------------------------------
02 Apr 2021 | 002 | Continued editing and refinement, added passed parameter
------------|-----|------------------------------------------------------------
02 Apr 2021 | 003 | Added try {code} catch {} to supress nagging errors where -ErrorAction SilentlyContinue does not work
------------|-----|------------------------------------------------------------
###############################################################################
#>

param ($passedIdentUsr)
$tryCount=0

function checkForParamInput {
    param ()
    if (!$passedIdentUsr) {
        $passedIdentUsr=Read-Host "You must enter a valid username"
    } elseif ($passedIdentUsr) {
        Write-Host $passedIdentUsr" seems to be correct.  Thank you"
        $Global:identUsr=try {(get-ADUser $passedIdentUsr).samaccountname} catch {}
        Write-Host $identUsr
    }
    # Check to see if entered username is a valid AD account
    $check4Validity=try {Get-ADUser $passedIdentUsr} catch {}
        if ($check4Validity) {
            $tryCount=0
            return
        } else {
            clear-Variable check4Validity,passedIdentUsr,identUsr
            $tryCount++
            Write-Host $tryCount.ToString()
            if ($tryCount -gt 3) {exit}
            checkForParamInput
        }
}

# $logonhours=@{"Logonhours"= [byte[]]$hours=@(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)}
# Declare and instantiate variables
$projectedExpirationDate="04/01/2021"
$DisabledUsersGroupID="127291"
$userDN=try {(Get-ADUser $identUsr).DistinguishedName} catch {}
$userTargetPath="OU=TerminatedEmployment,OU=Disabled-Staff and Faculty,DC=childdomain,DC=higheredinstitutionnameu,DC=edu"
$autoReplyMessage="Thank you for your email.  Please contact the higheredinstitutionname University operator at 757-727-5000 to reach the department you are inquiring about or visit higheredinstitutionname University’s website at https://www.higheredinstitutiondomain.edu."
$setADDSServer="addsdcserver01.childdomain.higheredinstitutiondomain.edu"
$extendedProperties=@{"Logonhours"= [byte[]]$hours=@(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);primaryGroupID=$DisabledUsersGroupID;employeeType="Terminated"}

function generateStrongRandomPassword {
    param ()
    # Import System.Web assembly
    Add-Type -AssemblyName System.Web
    # Generate random password with 30 characters and 15 special chracters
    $strongClearPass=[System.Web.Security.Membership]::GeneratePassword(30,15)
    $global:rndmPass=ConvertTo-SecureString -AsPlainText $strongClearPass -Force
    Write-Host "Generating strong password -- $strongClearPass " -ErrorAction SilentlyContinue
}

function disableAccountinAD {
    param ()
    # Disable account
    Write-Host "Disabling account." -ErrorAction SilentlyContinue
    Set-ADUser `
        -Server $setADDSServer `
        -Identity $identUsr `
        -Enabled $false `
        -LogonWorkstations 'nonexx' `
        -Replace $extendedProperties `
        -PostalCode 'd23668' `
        -CannotChangePassword $true `
        -Manager $null `
        -HomePage $null `
        -ScriptPath $null

    # Expire account.  Set one day after actual desired date.
    Write-Host "Expiring account to projected date." -ErrorAction SilentlyContinue
    Set-ADAccountExpiration `
        -Server $setADDSServer `
        -Identity $identUsr `
        -DateTime $projectedExpirationDate

    # Set password to "random" password
    Write-Host "Reseting password." -ErrorAction SilentlyContinue
    Set-ADAccountPassword `
        -Server $setADDSServer `
        -Identity $identUsr `
        -reset `
        -NewPassword $rndmPass `
}

function removeMemberFromGroups {
    param ()
    # Remove account from distribution and security groups
    Write-Host "Removing member from security/distribution groups.  Ignore errors about primary group." -ErrorAction SilentlyContinue
    $currGroupMembership=try {(Get-ADPrincipalGroupMembership $identUsr).name} catch {}
    foreach ($gp in $currGroupMembership) {
        try {
            Remove-ADPrincipalGroupMembership `
                -Server $setADDSServer `
                -Identity $identUsr `
                -MemberOf $gp `
                -Confirm:$false `
                -ErrorAction SilentlyContinue
        } catch {}
        
    }
}

function moveUserAccountToOU {
    param ()
    # Move user account to proper OU
    Write-Host "Moving account to proper OU." -ErrorAction SilentlyContinue
    Move-ADObject `
        -Server $setADDSServer `
        -Identity $userDN `
        -TargetPath $userTargetPath
}

function checkForExchangeModuleLoaded {
    param ()
    Write-Host "Checking to see if Exchange Module is loaded.  Ignore errors related to 'Get-ExchangeServer'." -ErrorAction SilentlyContinue
    # Ensures there are no lingering values
    Remove-Variable chkExchSvr -ErrorAction SilentlyContinue
    # Check to see if this is run from a session with the Exchange Management Shell module loaded
    $chkExchSvr=Get-ExchangeServer
    if ($chkExchSvr) {
        write-Host "Exchange Module loaded"
        return
    }   else {
        Write-Host "Exchange Module not loaded. Exiting"
        end
    }
}

function setExchangeMailboxSettings {
    param ()
    # Ensures there are no lingering values
    Remove-Variable doesUserHaveMailbox -ErrorAction SilentlyContinue
    # Check to see if running in Exchange Management Shell minus the "-version 2" switch (see syntax below)
    # C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noexit -command ". 'C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1'; Connect-ExchangeServer vexchserver01.childdomain.higheredinstitutiondomain.edu; cd $env:userprofile; Get-ExchangeServer"
    Write-Host "If Exchange module is loaded, now checking to see if user has a mailbox." -ErrorAction SilentlyContinue
    $doesUserHaveMailbox=get-Mailbox -Identity $identUsr -ErrorAction SilentlyContinue
    if ($doesUserHaveMailbox) {
        Write-Host "User $identUsr does have a mailbox.  Setting autoreply, removing from GAL, and setting send limit to 0MB." -ErrorAction SilentlyContinue
        # Set autoreply, disable GAL, and set receive limit to 0MB
        Set-MailboxAutoReplyConfiguration `
            -Identity $identUsr `
            -AutoReplyState Enabled `
            -InternalMessage $autoReplyMessage `
            -ExternalMessage $autoReplyMessage
        Set-Mailbox `
            -Identity $identUsr `
            -HiddenFromAddressListsEnabled $true `
            -MaxSendSize 0mb
    } else {
        Write-Host "User $identUsr does not have a mailbox." -ErrorAction SilentlyContinue
    }
}

function end {
    exit
}

function main {
    checkForParamInput
    generateStrongRandomPassword
    disableAccountinAD
    removeMemberFromGroups
    moveUserAccountToOU
    checkForExchangeModuleLoaded
    setExchangeMailboxSettings
}

main