# Important information obfuscated (hostname, IP address, username, password, etc)

<#
###############################################################################

  Date Created:  14 Apr 2021
  Date Modified: 14 Apr 2021
  Version: 0.1
  Authored By: Darien Hawkins (Director, Computer Center)
  Purpose: To copy StarRez files

###############  Update History  ###############

   Date     | Seq |  Action
------------|-----|------------------------------------------------------------
14 Apr 2021 | 001 | Initial draft, (Hawkins)
------------|-----|------------------------------------------------------------

###############################################################################
#>

# Declare script variables
$baseArgosFolder="\\DellGenericFileServer01\reports$\Argos_Evisions"
$subArgosFolder="StarRez"
$subArgosArchiveFolder="StarRez-Archive-AfterMovedandProcessed"
$starRezDestFolder="\\genericserver04\StarRezTransferFiles\DailyDatafiles"

function checkforExistence {
    # Check for the file before proceeding
    $isFileThere=Test-Path $baseArgosFolder\$subArgosFolder\*.txt
    if ($isFileThere) {
        Write-Host "File found, processing" -ErrorAction SilentlyContinue
        copyAndMoveFile
    } else {
        Write-Host "Not there" -ErrorAction SilentlyContinue
        exit
    }
}

function copyAndMoveFile {

    # Get name of the file
    $nameOfFile=(Get-ChildItem -Path $baseArgosFolder\$subArgosFolder\*.txt).name
    # Copy the files to the necessary locations
    Copy-Item -Path $baseArgosFolder\$subArgosFolder\*.txt -Destination $starRezDestFolder
    # Wait 15 seconds for file to process
    Start-Sleep -Seconds 15
    # If the file is found, meaning it was processed, delete the source file
    $isFileArchived=Test-Path -Path $starRezDestFolder\$nameOfFile
    if (!$isFileArchived) {
        Write-Host "file moved"
        Copy-Item -Path $baseArgosFolder\$subArgosFolder\$nameOfFile -Destination $baseArgosFolder\$subArgosFolder\$subArgosArchiveFolder
        Remove-Item -Path $baseArgosFolder\$subArgosFolder\$nameOfFile  -ErrorAction SilentlyContinue
    }
}

function main {
    checkforExistence
}

main