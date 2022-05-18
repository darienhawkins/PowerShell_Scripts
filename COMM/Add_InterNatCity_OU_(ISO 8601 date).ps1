<#
###############################################################################

  Date Created:     11 May 2022
  Date Modified:    12 May 2022
  Version:          1.0
  File Name:        Add_InterNatCity_OU_(ISO 8601 date).ps1
  Authored By:      Darien Hawkins (IT xxxx)
                    darien.hawkins@CompanyX.com
  Company:          CompanyX
  Department:       BBBXNA IT Dpt
  Purpose:          To programmatically create InterNatCity OU and sub
                    Desktops, Laptops, and Users OUs

###############  Update History  ##############################################
   Date     | Seq |  Action
------------|-----|------------------------------------------------------------
12 May 2021 | 002 | Minor edits and added top comment block
------------|-----|------------------------------------------------------------
11 May 2022 | 001 | Initial draft
------------|-----|------------------------------------------------------------
###############################################################################

-------------------------------------------------------------------------------

NOTES:

Go here, https://docs.microsoft.com/en-us/powershell/module/activedirectory/new-adorganizationalunit?view=windowsserver2022-ps

-------------------------------------------------------------------------------
#>

# Define variables
$costCenterOU="OU=369NotRealBA_CNTR,OU=369NotRealBA_Field_Project_eng",`
              "OU=369NotRealBC_CNTR,OU=369NotRealBC_EDM",`
              "OU=369NotRealBK_CNTR,OU=369NotRealBK_Mechanical_eng",`
              "OU=369NotRealBL_CNTR,OU=369NotRealBL_Structural_eng",`
              "OU=369NotRealBN_CNTR,OU=369NotRealBN_System_inte",`
              "OU=369NotRealBR_CNTR,OU=369NotRealBR_Autonomy_inte",`
              "OU=369NotRealHB_CNTR,OU=369NotRealHB_AutonomyProject",`
              "OU=369NotRealRB_CNTR,OU=369NotRealRB_R_D_Innovation_Group",`
              "OU=369NotRealRE_CNTR,OU=369NotRealRE_R_D_Test"
$pathOU='OU=DivX,OU=Companies,DC=OrgY,DC=CompanyX,DC=i'
$newOU="InterNatCity"
$newSubOU="Desktops","Laptops","Users"

foreach ($cur in $costCenterOU) {
    # Have to create the InterNatCity OU first
    # Wait for 1 second following each OU creation
    $InterNatCitypathOU="$cur,$pathOU"
    New-ADOrganizationalUnit -Name $newOU -Path $InterNatCitypathOU
    $InterNatCityNewPathOU="OU=$newOU,$cur,$pathOU"
    Start-Sleep 1
    foreach ($cursub in $newSubOU) {
        # Now create Desktop, Laptop, and Users OU under the InterNatCity OU
        # Wait for 1 second following each OU creation.
        New-ADOrganizationalUnit -Name $cursub -Path $InterNatCityNewPathOU
        Start-Sleep 1
    }
}