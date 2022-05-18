<#
    Permissions permitting, this will remove a user from all AD groups where an admin has rights to do so.
    For each group, the admin running the script will be prompted to confirm the removal action. Since "yes" is the default,
        the admin only has to hit the <enter> key to confirm action.
    The script will appear to pause as it enumerates the user's groups and populate the variable $usersADGroups.  Please be patient.
    The loop will skip "Domain User" and continue to the next group.
    For other groups outside of DivX control, will have to have IT admins who are responsible for that company to remove the user.
    If run from a Windows 10 client system (preferred), the admin must have
        "RSAT: Active Directory Domain Services and Lightweight Directory Services Tools" installed.
    For syntax documentation, see https://docs.microsoft.com/en-us/powershell/module/activedirectory/remove-adgroupmember?view=windowsserver2019-ps
#>

$userAcct="DivXxxxx" #User's samaccountname (login)
$domUsers="Domain Users"
$usersADGroups=(Get-ADPrincipalGroupMembership $userAcct).name|Sort-Object

foreach ($curADGroup in $usersADGroups)
{
    if ($curADGroup -eq $domUsers)
    {
        # If group is "Domain Users, do nothing and loop to the next group
    } else
    {
        Write-Host $curADGroup # Optional
        Remove-ADGroupMember -Identity $curADGroup -Members $userAcct
    }
}
