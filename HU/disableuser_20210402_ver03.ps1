<#
###############################################################################

  Date Created:  29 Mar 2021
  Date Modified: 06 Apr 2021
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
05 Apr 2021 | 004 | Allow parameter to allow pipeline input. Add 1-second sleep to prevent race condition
------------|-----|------------------------------------------------------------
06 Apr 2021 | 005 | Added looping logic ensuring primary group is changed
------------|-----|------------------------------------------------------------
###############################################################################
#>


param (
    [Parameter(ValueFromPipeline=$true)]
    $passedUserLoginName,
    [Parameter(ValueFromPipeline=$true)]
    $passedAccountExpirationDate
)

$tryCount=0


# $logonhours=@{"Logonhours"= [byte[]]$hours=@(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)}
# Declare and instantiate variables
$termListFolderBase="\\genericfileserver01\Shares\HUCCIT\Terminate_List"
$DisabledUsersGroupName="Disabled_Users"
$DisabledUsersGroupID="127291"
# $userObjectGUID=try {(Get-ADUser $identUsr).ObjectGUID} catch {}
$userTargetPath="OU=TerminatedEmployment,OU=Disabled-Staff and Faculty,DC=childdomain,DC=hamptonu,DC=edu"
$autoReplyMessage="Thank you for your email.  Please contact the Hampton University operator at 757-727-5000 to reach the department you are inquiring about or visit Hampton University’s website at https://www.higheredinstitutiondomain.edu."
$setADDSServer="addsdcserver01.childdomain.higheredinstitutiondomain.edu"
$extendedProperties=@{"Logonhours"= [byte[]]$hours=@(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);primaryGroupID=$DisabledUsersGroupID;employeeType="Terminated"}

function checkForParamInput {
    param ()
    if (!$passedUserLoginName) {
        $passedUserLoginName=Read-Host "You must enter a valid username"
    } elseif ($passedUserLoginName) {
        Write-Host $passedUserLoginName" seems to be correct.  Thank you"
        $Global:identUsr=try {(get-ADUser $passedUserLoginName).samaccountname} catch {}
        $Global:userObjectGUID=try {(Get-ADUser $identUsr).ObjectGUID} catch {}
        Write-Host $identUsr
    }
    if (!$passedAccountExpirationDate) {
        $Global:projectedExpirationDate=(get-date).date
    } else {
        $Global:projectedExpirationDate=$passedAccountExpirationDate
    }
    # Check to see if entered username is a valid AD account
    $check4Validity=try {Get-ADUser $passedUserLoginName} catch {}
        if ($check4Validity) {
            $tryCount=0
            return
        } else {
            clear-Variable check4Validity,passedUserLoginName,identUsr
            $tryCount++
            Write-Host $tryCount.ToString()
            if ($tryCount -gt 3) {end}
            checkForParamInput
        }
}

function generateStrongRandomPassword {
    param ()
    # Import System.Web assembly
    Add-Type -AssemblyName System.Web
    # Generate random password with 30 characters and 15 special chracters
    $strongClearPass=[System.Web.Security.Membership]::GeneratePassword(30,15)
    $global:rndmPass=ConvertTo-SecureString -AsPlainText $strongClearPass -Force
    Write-Host "Generating strong password -- $strongClearPass " -ErrorAction SilentlyContinue
}

function check4Disable_UsersAdd {
    $isDisable_UsersAdded=(Get-ADPrincipalGroupMembership -Server $setADDSServer -Identity $identUsr).name|select-string $DisabledUsersGroupName
    if ($isDisable_UsersAdded -like $DisabledUsersGroupName) {
        return
    } else {
        Start-Sleep -Seconds 2
        check4Disable_UsersAdd
    }
}

function checkChangePrimaryGroup {
    # We have to loop this since it can take a couple of cycles for the changes to take
    $isPrimaryGroup_127291=(Get-ADUser -Properties * $identUsr).primarygroupid
    if ($isPrimaryGroup_127291 -eq $DisabledUsersGroupID) {
        return
    } else {
        Start-Sleep -Seconds 2
        Write-Host $isPrimaryGroup_127291
        try {
            Set-ADUser `
                -Server $setADDSServer `
                -Identity $identUsr `
                -Replace @{primaryGroupID=$DisabledUsersGroupID}
        } catch {}
        checkChangePrimaryGroup
    }
}

function disableAccountinAD {
    param ()
    # Have to add member to "Disabled_Users" group first
    Write-Host "Adding $identUsr to 'Disabled_Users' group." -ErrorAction SilentlyContinue
    try {
        Add-ADGroupMember -Identity $DisabledUsersGroupName -Members $identUsr
    } catch {}
    # Call function to check and loop until check is complete
    check4Disable_UsersAdd
    # Disable account
    Write-Host "Disabling $identUsr account." -ErrorAction SilentlyContinue
    try {
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
    } catch {}
    # Call function to ensure primary group is changed to "Disabled_Users"
    checkChangePrimaryGroup
    # Expire account.  Set one day after actual desired date.
    Write-Host "Expiring $identUsr account to projected date: $projectedExpirationDate." -ErrorAction SilentlyContinue
    Set-ADAccountExpiration `
        -Server $setADDSServer `
        -Identity $identUsr `
        -DateTime $projectedExpirationDate
    # Set password to "random" password
    Write-Host "Reseting $identUsr password." -ErrorAction SilentlyContinue
    Set-ADAccountPassword `
        -Server $setADDSServer `
        -Identity $identUsr `
        -reset `
        -NewPassword $rndmPass `
}

function removeMemberFromGroups {
    param ()
    Start-Sleep -Seconds 10
    # Remove account from distribution and security groups
    Write-Host "Removing $identUsr from security/distribution groups.  Ignore errors about primary group." -ErrorAction SilentlyContinue
    $currGroupMembership=try {(Get-ADPrincipalGroupMembership $identUsr).name} catch {}
    # Write current group membership for archive
    $writeDate=get-date -Format yyyyMMddHHmmss
    $currGroupMembership | Out-File "$termListFolderBase\UserGroupMemberships\$identUsr-$writeDate.txt"
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
    Start-Sleep -Seconds 1
    # Move user account to proper OU
    Write-Host "Moving $identUsr account to proper OU." -ErrorAction SilentlyContinue
    Write-Host $userObjectGUID $identUsr $setADDSServer $userTargetPath
    Move-ADObject `
        -Server $setADDSServer `
        -Identity $userObjectGUID `
        -TargetPath $userTargetPath
}

function checkForExchangeModuleLoaded {
    param ()
    Start-Sleep -Seconds 1
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
        end
    }
}

function end {
    exit
}

function main {
    param ()
    checkForParamInput
    generateStrongRandomPassword
    disableAccountinAD
    removeMemberFromGroups
    moveUserAccountToOU
    checkForExchangeModuleLoaded
    setExchangeMailboxSettings
}

main