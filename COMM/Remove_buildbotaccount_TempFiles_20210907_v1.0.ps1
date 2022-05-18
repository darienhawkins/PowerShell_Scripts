<#
###############################################################################

  Date Created:     07 Sep 2021
  Date Modified:    07 Sep 2021
  Version:          1.0
  File Name:        Remove_buildbotaccount_TempFiles_20210907_v1.0.ps1
  Authored By:      Darien Hawkins (IT xxxx)
                    darien.hawkins@CompanyX.com
  Company:          CompanyX
  Department:       BBBXNA IT Dpt
  Purpose:          To programmatically remove unnecessary files temp files from C:\Users\buildbotaccount\AppData\Local\Temp

###############  Update History  ##############################################
   Date     | Seq |  Action
------------|-----|------------------------------------------------------------
07 Sep 2021 | 001 | Initial draft
------------|-----|------------------------------------------------------------
###############################################################################
#>

$usrEnvTempFolder="C:\Users\buildbotaccount\AppData\Local\Temp"
Get-ChildItem $usrEnvTempFolder | `
    Where-Object {$_.LastWriteTime -lt (get-date).AddDays(-10)} | `
    Remove-Item -Recurse -Force