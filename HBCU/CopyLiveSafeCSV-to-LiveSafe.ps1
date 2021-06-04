# Important information obfuscated (hostname, IP address, username, password, etc)

$portableAppsPath="C:\Portable_Apps"
$localLiveSafePath="C:\LiveSafe"
$liveSafeFilename="livesafe_snapshot"
$privateSSHKey="SSHPrivateKey_Generated_20200904.ppk"
$curDateTimeStamp=get-date -Format yyyyMMddTHHmmss

function renameCopytoArchive {
  Copy-Item $localLiveSafePath\$liveSafeFilename.csv $localLiveSafePath\Archive\$liveSafeFilename"_"$curDateTimeStamp.csv
  if (Test-Path $localLiveSafePath\Archive\$liveSafeFilename"_"$curDateTimeStamp.csv) {
    Remove-Item $localLiveSafePath\$liveSafeFilename.csv
  }
}

# "C:\LiveSafe\etc\LiveSafe_WinSCP.ini"

function copyViaWinSCP {
  & "$portableAppsPath\WinSCP\WinSCP.com" `
  /log="$localLiveSafePath\Logs\uploadlog_$curDateTimeStamp.log" /ini="$localLiveSafePath\etc\LiveSafe_WinSCP.ini" `
  /command `
    "bin" `
    "open sftp://guidaddress@aaa.bbb.ccc.ddd:xxxx/ -hostkey=`"`"ssh-xxx=`"`" -privatekey=`"`"$localLiveSafePath\Keys\$privateSSHKey`"`" -passphrase=`"`"obfuscatedpass`"`"" `
    "put $localLiveSafePath\$liveSafeFilename.csv -nopreservetime -nopermissions" `
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

function check4LiveSafeFile {
  if (!(Test-Path $localLiveSafePath\$liveSafeFilename.csv)) {
    Write-Host "File not found"
    Exit
  } else {
    copyViaWinSCP
  }
}

function main {
  check4LiveSafeFile
}

main