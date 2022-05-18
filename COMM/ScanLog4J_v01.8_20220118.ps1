<#
###############################################################################

  Date Created:     17 Dec 2021
  Date Modified:    18 Jan 2022
  Version:          1.8
  File Name:        ScanLog4J_v01.8_20220118.ps1
  Authored By:      Darien Hawkins (IT xxxx)
                    darien.hawkins@CompanyX.com
  Company:          CompanyX
  Department:       BBBXNA IT Dpt
  Purpose:          To programmatically scan for log4j vulnerable classes in
                    JAR and WAR files

###############  Update History  ##############################################
   Date     | Seq |  Action
------------|-----|------------------------------------------------------------
18 Jan 2022 | 008 | Added capability to scan all local fixed drives
------------|-----|------------------------------------------------------------
06 Jan 2022 | 007 | Added the folder "c:\windows\ccmcache\*" to be excluded from scans
------------|-----|------------------------------------------------------------
22 Dec 2021 | 006 | Added logic to terminate running process and delete "old" fies
                  |  Refactored into discrete functions
------------|-----|------------------------------------------------------------
20 Dec 2021 | 005 | Modified for distribution
------------|-----|------------------------------------------------------------
17 Dec 2021 | 004 | Added logic for creation of "onlyindicators" file
------------|-----|------------------------------------------------------------
17 Dec 2021 | 003 | Minor edits
------------|-----|------------------------------------------------------------
17 Dec 2021 | 002 | Minor edits
------------|-----|------------------------------------------------------------
17 Dec 2021 | 001 | Initial draft
------------|-----|------------------------------------------------------------
###############################################################################

-------------------------------------------------------------------------------

NOTES:

Go here, https://github.com/hillu/local-log4j-vuln-scanner/releases, to get the latest release.
Place all files into a local folder on the target computer (i.e. c:\temp)

When invoking the sciptt, we may want to ensure we use the -ExecutionPolicy unrestricted argument to ensure the script is run.
  C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy unrestricted <path>\<scriptname>

-------------------------------------------------------------------------------
#>

# Define variables
$allDrives=(get-volume | Where-Object DriveType -eq "Fixed" | Where-Object DriveLetter -ne $null).driveletter
$dateScanRan=Get-Date
$scannerFoler="C:\ProgramData\CompanyX\log4jScanner"
$scanFileName="$env:COMPUTERNAME-local-log4j-vuln-scan.txt"
$scanFileNameOnlyIndicators="$env:COMPUTERNAME-local-log4j-vuln-scan_OnlyIndicators.txt"
$folder0ToExclude="c:\windows\ccmcache"
$folder1ToExclude="C:\windows\ccmcache"
$folder2ToExclude="C:\Windows\ccmcache"
$folder3ToExclude="c:\Windows\ccmcache"
$arguments="--quiet --exclude $folder0ToExclude --exclude $folder1ToExclude --exclude $folder2ToExclude --exclude $folder3ToExclude --log $scannerFoler\scan\$scanFileName c:\"
$scannerFileName="local-log4j-vuln-scanner.exe"
$networkLocation="\\server\servershare\ITDept\Security\log4j_Scans"
$appendedText="`n`n Scan for computer $env:COMPUTERNAME conducted on $dateScanRan."
$currentFolderLocation=(Get-Location).Path

function CreateFoldersCopyExecutable {
    # Creates folders if necessary
    New-Item -Type Directory $scannerFoler -ErrorAction SilentlyContinue
    New-Item -Type Directory $scannerFoler\scan -ErrorAction SilentlyContinue
    # Copies local-log4j-vuln-scanner.exe and overwrites existing version
    Copy-Item $currentFolderLocation\$scannerFileName $scannerFoler -Force -ErrorAction SilentlyContinue
}

function StopCurrentRunningInstance {
    # If scan is already running, terminate
    $stopIfRunning=(get-process -ProcessName local-log4j-vuln-scanner -ErrorAction SilentlyContinue).processname
    if ($stopIfRunning) {
        Stop-Process -Force -ProcessName $stopIfRunning
        DeleteExistingLogFiles
    }
    CreateFoldersCopyExecutable
}

function DeleteExistingLogFiles {
    # If previous scan found, delete files from C:\ProgramData\CompanyX\log4jScanner\scan folder so fresh files are generated
    $isLogThere=Test-Path -path $scannerFoler\scan\*
    if ($isLogThere) {
        Remove-Item -path $scannerFoler\scan\* -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
}

function RunScan {
    # Runs the scan, outputs the log
    foreach ($currDrive in $allDrives) {
        $scandrive=$currDrive+":\"
        $arguments="--quiet --exclude $folder0ToExclude --exclude $folder1ToExclude --exclude $folder2ToExclude --exclude $folder3ToExclude --log $scannerFoler\scan\$scanFileName_$currDrive $scandrive"
        Start-Process -FilePath $scannerFoler\local-log4j-vuln-scanner.exe -ArgumentList $arguments -Wait -NoNewWindow
    }
}

function CreateAppendCopyLogs {
    # If indicator is found, make a seperate file, otherwise, just produce the scan
    $isIndicatorThere=Get-Content -path $scannerFoler\scan\$scanFileName | Select-String "indicator for vulnerable component"
    if ($isIndicatorThere) {
        Out-File -Encoding utf8 -FilePath $scannerFoler\scan\$scanFileNameOnlyIndicators -InputObject $isIndicatorThere
        Out-File -Encoding utf8 -FilePath $scannerFoler\scan\$scanFileNameOnlyIndicators -InputObject $appendedText -Append
    }

    # Appends computer name and date to bottom of file
    Out-File -Encoding utf8 -FilePath $scannerFoler\scan\$scanFileName -InputObject $appendedText -Append

    # Copy files to network location and create a local conditions file
    Copy-Item $scannerFoler\scan\$scanFileName $networkLocation -Force -ErrorAction SilentlyContinue
    Copy-Item $scannerFoler\scan\$scanFileNameOnlyIndicators $networkLocation -Force -ErrorAction SilentlyContinue
    New-Item -ItemType File $scannerFoler\scan\scancompleted -Force -ErrorAction SilentlyContinue
}

function main {
    StopCurrentRunningInstance
    DeleteExistingLogFiles
    RunScan
    CreateAppendCopyLogs
}

main
