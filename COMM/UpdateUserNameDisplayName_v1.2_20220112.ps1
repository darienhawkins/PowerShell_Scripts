<#
###############################################################################

  Date Created:     06 Jan 2022
  Date Modified:    12 Jan 2022
  Version:          1.2
  File Name:        UpdateUserNameDisplayName_v1.1_20220106.ps1
  Authored By:      Darien Hawkins (IT xxxx)
                    darien.hawkins@CompanyX.com
  Company:          CompanyX
  Department:       BBBXNA IT Dpt
  Purpose:          To programmatically rename user accounts

###############  Update History  ##############################################
   Date     | Seq |  Action
------------|-----|------------------------------------------------------------
12 Jan 2022 | 002 | Updated to query the cost center from the department field
------------|-----|------------------------------------------------------------
06 Jan 2022 | 001 | Initial draft
------------|-----|------------------------------------------------------------
###############################################################################

-------------------------------------------------------------------------------

NOTES: NA

-------------------------------------------------------------------------------
#>

function UpdateUser {
    $USACompXDivXusers=(Get-ADUser -properties * -Filter {department -like $oldAppend})
    foreach ($curUSACompXUser in $USACompXDivXusers) {
        $lastN=(Get-ADUser $curUSACompXUser).surname
        $firstN=(Get-ADUser $curUSACompXUser).givenname
        $curN=(Get-ADUser $curUSACompXUser).name
        $userGUID=(Get-ADUser $curUSACompXUser).ObjectGUID
        $newN="$lastN $firstN $newAppend"
        Write-Host "OLD: = $curN --> New: $newN"
        ##### This is the area where the rename happens #############
        Set-ADUser -Identity $curUSACompXUser -DisplayName $newN
        Rename-ADObject -Identity $userGUID -NewName $newN
        #############################################################
    }
}

$division=1,2,3,4,5,6,7,8,9,10,11,12,13
foreach ($curDivision in $division) {
    switch ($curDivision)
    {
        1 {$oldAppend="*A-00121";$newAppend="(USACompX)";UpdateUser}
        2 {$oldAppend="*B-00121";$newAppend="(USACompX-EMT)";UpdateUser}
        3 {$oldAppend="*C-00121";$newAppend="(USACompX-MIN)";UpdateUser}
        4 {$oldAppend="*F-00121";$newAppend="(USACompX-LMT)";UpdateUser}
        5 {$oldAppend="*G-00121";$newAppend="(USACompX-LWE)";UpdateUser}
        6 {$oldAppend="*H-00121";$newAppend="(USACompX-TDK)";UpdateUser}
        7 {$oldAppend="*L-00121";$newAppend="(USACompX-HAU)";UpdateUser}
        8 {$oldAppend="*M-00121";$newAppend="(USACompX-COT)";UpdateUser}
        9 {$oldAppend="*D-00121*";$newAppend="(USACompX-MCC-MC)";UpdateUser}
        10 {$oldAppend="*E-00121";$newAppend="(USACompX-MCC-CC)";UpdateUser}
        11 {$oldAppend="*D1-00121*";$newAppend="(USACompX-MCC-MC)";UpdateUser}
        12 {$oldAppend="*D0-00121*";$newAppend="(USACompX-MCC-MC)";UpdateUser}
        13 {$oldAppend="*D00-00121*";$newAppend="(USACompX-MCC-MC)";UpdateUser}
    }
}

