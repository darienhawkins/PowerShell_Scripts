<#
    Auth: Hawkins, Darien H
          Director, Computer Center
    
    |--------------|---------|----------------------------------------------------
    |     Date     | Version | Action
    |--------------|---------|----------------------------------------------------
    | 05 Feb 2021  |  0.0.1  | Initital
    |--------------|---------|----------------------------------------------------
    
    Uploads files to Simplicity via WinSCP.com
    This script must be run from HUITAPPWXAGNT01 (IP: 137.198.11.60)
#>

# Declare variables
$winSCPLoc="\\huitsvr01\systems\_Tools\WinSCP"
#$simplFileLoc="\\huitsvr01\systems\BannerProd\Student\Datafiles\Symplicity_Files"
$simplFileLoc="\\huitsvr01\reports$\Argos_Evisions\Simplicity"
$simplArchiveFolder="Simplicity-Archive-AfterMovedandProcessed"
$logFileLoc="$simplFileLoc\Log"
$timeStamp=(get-date -Format yyyyMMddTHHmm).ToString()

function testForFileExistance {
  # Test for the existance of a file.  If no file, exit.
  $isFileThere=(Test-Path $simplFileLoc\Simplicity*txt)
  if ($isFileThere) {
    runWinSCPCopyFiles
  } else {
    Write-Host "No Files to Copy"  -ErrorAction SilentlyContinue
    Exit
  }
}

function runWinSCPCopyFiles {
  # Call WinSCP.com and upload file, write log with time stamp
  & "$winSCPLoc\WinSCP.com" `
  /log="$simplFileLoc\Log\Simplicity_WinSCP-$timeStamp.log" /ini=nul `
  /command `
    "open sftp://hamptonudrop:ebjkar6nmr8m98@hamptonu-csm.drop.symplicity.com/ -hostkey=`"`"ssh-ed25519 255 GSs8YtW+d+T5siKb3d6jsUQQassglS8W/Jgxw2CNG9Q=`"`"" `
    "put $simplFileLoc\Simplicity* -nopreservetime -nopermissions" `
    "exit"

  # If sucessful, move files to archive folder
  $winscpResult = $LastExitCode
  if ($winscpResult -eq 0)
  {
    Write-Host "Upload to Simplicity successfull" -ErrorAction SilentlyContinue
    Copy-Item $simplFileLoc\Simplicity*txt $simplFileLoc\$simplArchiveFolder
    Remove-Item $simplFileLoc\Simplicity*txt
  }
  else
  {
    Write-Host "Error.  Oops, something happened"  -ErrorAction SilentlyContinue
  }

  exit $winscpResult
}

function main {
  testForFileExistance
}

main