# Important information obfuscated (hostname, IP address, username, password, etc)

$portableAppsPath="C:\Portable_Apps"
$localapplicationName01Path="C:\applicationName01"
$applicationName01Filename="applicationName01_snapshot"
$privateSSHKey="SSHPrivateKey_Generated_20200904.ppk"
$curDateTimeStamp=get-date -Format yyyyMMddTHHmmss

function renameCopytoArchive {
  Copy-Item $localapplicationName01Path\$applicationName01Filename.csv $localapplicationName01Path\Archive\$applicationName01Filename"_"$curDateTimeStamp.csv
  if (Test-Path $localapplicationName01Path\Archive\$applicationName01Filename"_"$curDateTimeStamp.csv) {
    Remove-Item $localapplicationName01Path\$applicationName01Filename.csv
  }
}

# "C:\applicationName01\etc\applicationName01_WinSCP.ini"

function copyViaWinSCP {
  & "$portableAppsPath\WinSCP\WinSCP.com" `
  /log="$localapplicationName01Path\Logs\uploadlog_$curDateTimeStamp.log" /ini="$localapplicationName01Path\etc\applicationName01_WinSCP.ini" `
  /command `
    "bin" `
    "open sftp://guidaddress@192.123.234.123:1234/ -hostkey=`"`"ssh-xxx=`"`" -privatekey=`"`"$localapplicationName01Path\Keys\$privateSSHKey`"`" -passphrase=`"`"obfuscatedpass`"`"" `
    "put $localapplicationName01Path\$applicationName01Filename.csv -nopreservetime -nopermissions" `
    "exit"

  $winscpResult = $LastExitCode
  if ($winscpResult -eq 0)
  {
    Write-Host "Success"
    renameCopytoArchive
  }
  else
  {
    Write-Host "Error"
  }

  exit $winscpResult
}

function check4applicationName01File {
  if (!(Test-Path $localapplicationName01Path\$applicationName01Filename.csv)) {
    Write-Host "File not found"
    Exit
  } else {
    copyViaWinSCP
  }
}

function main {
  check4applicationName01File
}

main