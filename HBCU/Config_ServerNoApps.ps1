﻿# Important information obfuscated (hostname, IP address, username, password, etc)

<#
    Date: March 13, 2019
    Ver:  0.9
    Auth: Darien Hawkins
    Purpose: To configure new server install
#>

# Read-Host -Prompt "hit a key"
# Declare variables
# $appInstBaseDir=(Get-Location).ProviderPath
$appInstBaseDir="\\DellGenericFileServer01\Shares\Applications\_BaselineAppInstaller"
$shortcutLoc=$appInstBaseDir+"\shortcuts"
$ploc="somepassword"
$wallPaperDir=$env:windir+"\Web\Wallpaper"
$higherEdWallPaper="higheredinstitutionnameU_v3_Server.jpg"
$configLoc=$appInstBaseDir+"\Configs\higheredinstitutionnameUniversity"
$userAccPics=$env:ProgramData+"\Microsoft\User Account Pictures"
$appsToInstall=Import-Csv $configLoc\AppsToInstall.txt
$regFiles="DisableSmartScreenTemp.reg","HigherEDReg-Server.reg","enableRDP.reg"
$pass=ConvertTo-SecureString -String $ploc -AsPlainText -Force
$localUsr="somelocaladminaccount"
$localUsrDesc="Local account for administering the computer"

Clear-Host

# Process Configs
dism /online /enable-feature /featurename:telnetclient
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
foreach ($iptreg in $regFiles) {reg import $configLoc\$iptreg}
netsh advfirewall import $configLoc\higheredbaselineFWRules.wfw
winrm quickconfig -quiet -force

Clear-Host

<#

# Install applications from config file
foreach ($appToInst in $appsToInstall) {
    Write-Host $appToInst.name
    Start-Process -FilePath $appToInst.name -ArgumentList $appToInst.arg -Wait -PassThru -WorkingDirectory $appInstBaseDir
    }

Clear-Host

#>


# Create necessary custom directories
mkdir $env:SystemDrive\Temp -ErrorAction SilentlyContinue
mkdir $wallPaperDir\higheredinstitutionnameU -ErrorAction SilentlyContinue
mkdir $userAccPics\OEM -ErrorAction SilentlyContinue
mkdir $env:ProgramData\higheredinstitutionnameU -ErrorAction SilentlyContinue


# Delete unecessary items, remove JAVA update binaries, cleanup
Remove-Item $userAccPics\*.dat -Force -ErrorAction SilentlyContinue

# Copy HigherED custom Files
Copy-Item $configLoc\$higherEdWallPaper $wallPaperDir\higheredinstitutionnameU -ErrorAction SilentlyContinue
Copy-Item $userAccPics\*.* $userAccPics\OEM -ErrorAction SilentlyContinue
Copy-Item $configLoc\UserAccountPictures\*.* $userAccPics\ -ErrorAction SilentlyContinue

# Import LGPO Settings and default Start Layout
Start-Process -FilePath $appInstBaseDir\LGPO\LGPO.exe -ArgumentList "/g $configLoc\LocalGroupPolicy"
# Import-StartLayout -MountPath $env:SystemDrive\ -LayoutPath $configLoc\higheredbaselineinstall_v02.xml

Clear-Host

# Add departmentsharefolderCC local user
New-LocalUser -Name $localUsr -Password $pass -PasswordNeverExpires -Description $localUsrDesc
Add-LocalGroupMember -Group "administrators" -Member $localUsr

# CD back to system drive
cd $env:SystemDrive

Clear-Host

Write-Host "Install complete (from what we can tell).  Please restart computer."
