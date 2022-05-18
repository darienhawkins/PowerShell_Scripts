<#
###############################################################################

  Date Created:     02 Feb 2022
  Date Modified:    02 Feb 2022
  Version:          1.0
  Authored By:      Darien Hawkins (IT xxxx)
                    darien.hawkins@CompanyX.com
  Company:          CompanyX
  Department:       BBBXNA IT Dpt
  Purpose:          To programmatically delete files older than a specified
                    number of days. Does not recurse through subdirectories.

###############  Update History  ##############################################
   Date     | Seq |  Action
------------|-----|------------------------------------------------------------
01 Feb 2022 | 001 | Initial draft
------------|-----|------------------------------------------------------------
###############################################################################

-------------------------------------------------------------------------------

NOTES: NA

-------------------------------------------------------------------------------
#>

$logPath="C:\TempBBB\ProgramData\CompanyX\CompanyX BBB Portal\Logs"
$pastDays=-7
$daysAgo=(Get-Date).AddDays($pastDays)
Get-ChildItem -Path $logPath | `
    Where-Object {$_.LastWriteTime -lt $daysAgo} | `
    Remove-Item