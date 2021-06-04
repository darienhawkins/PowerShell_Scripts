# Important information obfuscated (hostname, IP address, username, password, etc)

<#
    Auth: Hawkins, Darien H
          Director, Computer Center
    
    |--------------|---------|----------------------------------------------------
    |     Date     | Version | Action
    |--------------|---------|----------------------------------------------------
    | 05 Feb 2021  |  0.0.1  | Initital
    |--------------|---------|----------------------------------------------------
    
    Uploads files to Simplicity via WinSCP.com
    This script must be run from schedserver01 (IP: aaa.bbb.11.60)
#>

# Declare variables
$winSCPLoc="\\DellGenericFileServer01\systems\_Tools\WinSCP"
#$simplFileLoc="\\DellGenericFileServer01\systems\BannerProd\Student\Datafiles\Symplicity_Files"
$simplFileLoc="\\DellGenericFileServer01\reports$\Argos_Evisions\Simplicity"
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
    "open sftp://higheredinstitutionnameudrop:ebjkar6nmr8m98@higheredinstitutionnameu-csm.drop.obfuscatedvendorcompany.com/ -hostkey=`"`"ssh-ed25519 255 xxxxxx=`"`"" `
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