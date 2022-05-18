# Important information obfuscated (hostname, IP address, username, password, etc)

<#
    Date: Oct 17, 2019
    Ver:  2.0.1
    Auth: Hawkins, Darien H
          Director, Computer Center

    |--------------|---------|----------------------------------------------------
    |     Date     | Version | Action
    |--------------|---------|----------------------------------------------------
    | Oct 25, 2019 |  1.0.0  | Initial Script to install SEP remotely.  
    |              |         | WinRM must be enabled for this to work.
    |--------------|---------|----------------------------------------------------

    
#>


$nameSpace="Microsoft.PowerShell.Core\FileSystem::"
$sepName="setup.exe"
$sepSouce="$nameSpace\\fileserver01\Shares\Symantec Endpoint\Symantec Endpoint 14\LatestVersion"
$desComp="installtest01" 
$desCompUNC="$nameSpace\\$desComp"
$newTempDir="Temp"
$usrCred="higheredchilddomain\person1.adm"

New-Item -ItemType Directory -Path $desCompUNC\c$\$newTempDir -ErrorAction SilentlyContinue
Copy-Item $sepSouce\$sepName $desCompUNC\c$\$newTempDir -Force
Invoke-Command -ComputerName $desComp -Credential $usrCred -ScriptBlock {cmd /c c:\temp\setup.exe}
shutdown -t 600 -r -f -c "Computer will restart in 10 mimutes following SEP update" -m $desComp
