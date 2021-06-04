# Important information obfuscated (hostname, IP address, username, password, etc)

<#
Auth: Hawkins, Darien H
    Director, Computer Center
    
--------------|---------|----------------------------------------------------
     Date     | Version | Action
--------------|---------|----------------------------------------------------
 Sep 03, 2020 |  2.1.6  | Check for both version 1909 and 2004 to proceed
--------------|---------|----------------------------------------------------
 Aug 27, 2020 |  2.1.5  | Added check for existance of Office 2016.
--------------|---------|----------------------------------------------------
 Aug 10, 2020 |  2.1.4  | Reorg code, broke up installer scripts
              |         | Call seperate update-help script
              |         | Comment out Adobe font install script
--------------|---------|----------------------------------------------------
 Jul 08, 2020 |  2.1.3  | Updated Altertus Installer msi
                        | Call seperate Adobe font install script
--------------|---------|----------------------------------------------------
 Mar 20, 2020 |  2.1.2  | Reorg code, move SEP to seperate line
--------------|---------|----------------------------------------------------
 Dec 10, 2019 |  2.1.1  | Updated to update to Windows ver.1909
--------------|---------|----------------------------------------------------
 Oct 25, 2019 |  2.1.0  | Added abilit to install fonts, refactored variables
--------------|---------|----------------------------------------------------
 Oct 17, 2019 |  2.0.1  | Updated $upgradeAssistantPath= path
--------------|---------|----------------------------------------------------
    
    
#>


# Read-Host -Prompt "hit a key"
# Declare variables
$sourceShare="\\DellGenericFileServer01\Shares"
$appInstBaseDir=$sourceShare+"\Applications\_BaselineAppInstaller"
$shortcutLoc=$appInstBaseDir+"\shortcuts"
$ploc="somepassword"
$ploc2="someotherpassword"
$wallPaperDir=$env:windir+"\Web\Wallpaper"
$huWallpaper="higheredinstitutionnameU_2018_01.jpg"
$configLoc=$appInstBaseDir+"\Configs\higheredinstitutionnameUniversity"
$userAccPics=$env:ProgramData+"\Microsoft\User Account Pictures"

#$appsToInstall=Import-Csv $configLoc\AppsToInstall.txt

$regFiles="DisableSmartScreenTemp.reg","HUOEMReg.reg","enableRDP.reg"
$pass=ConvertTo-SecureString -String $ploc -AsPlainText -Force
$pass2=ConvertTo-SecureString -String $ploc2 -AsPlainText -Force
$localUsr="somelocaladminaccount"
$localUsr2="higheredinstitutionname"
$localUsrDesc="Local account for administering the computer"
$notificationText="Install and configuration complete.  Computer will reboot in 60 seconds (1 minute). Please run Windows updates and activate Office 2016 following system reboot."
$messageBoxTitle="Configuration Complete/Reboot Notification"
$proceedWithInstall="Proceeding with application install and configuration.  The computer will reboot automatically at completion."
$latestWinVer="1909 or 2004"
$upgradeAssistantPath=$sourceShare+"\OS_Installs\Win10-Version-Upgrade\setup-$latestWinVer.lnk"
$checkWinVer=[System.Environment]::OSVersion.VersionString
$dots="......................................................................................"
$counter=0

# Declare Windows 1909 Update Function
function updateToLatestWindowsVersion {
    Start-Process -FilePath $upgradeAssistantPath
    Start-Sleep -s 15
    exit
    }


# Check to see if current instance is Windows
if ($checkWinVer -like "*18363*" -or $checkWinVer -like "*19041*") {
    Clear-Host
    if ($checkWinVer -like "*18363*") {
        Write-Host "Windows is running verson 1909. $proceedWithInstall"
    }
    if ($checkWinVer -like "*19041*") {
        Write-Host "Windows is running verson 2004. $proceedWithInstall"
    }
    # (old code) Write-Host "Windows is running verson 1909 or 2004. $proceedWithInstall"
    Start-Sleep -s 5 } else {
    Clear-Host
    Write-Host $dots
    Write-Host "This installation of Windows 10 is not version $latestWinVer."
    Write-Host "It is higly recommened to upgrade now to save time and bandwidth later."
    do {$instAnswer=Read-Host -Prompt "Do you want to run the Windows Upgrade Wizard (recommended)? (y/n)"} 
        until ("y","n" -ccontains $instAnswer)
    if ($instAnswer -eq "y") {
        Clear-Host
        Write-Host $dots
        Write-Host "Will start upgrade process now."
        Write-Host "Be sure to keep both 'Install Windows 10' and 'Keep personal files and apps' options selected."
        Write-Host "The $latestWinVer upgrade can take over an hour to complete.  Please be patient."
        Write-Host "After Windows 10 is upgraded to $latestWinVer, please rerun this script to complete application installs and OS configuration."
        updateToLatestWindowsVersion
        } else {
        Write-Host " " $proceedWithInstall
        Start-Sleep -s 5
        }
    }


# Start installation of Adobe fonts in parallel with this script
# Start-Process -WindowStyle Minimized powershell -ArgumentList "\\DellGenericFileServer01\Shares\Applications\_BaselineAppInstaller\scripts\InstallAdobeFonts.ps1"
# Start-Job -FilePath "\\DellGenericFileServer01\Shares\Applications\_BaselineAppInstaller\scripts\InstallAdobeFonts.ps1"

# Update Powershell help in a seperate, minimized window runnning in parallel to this installer script
#Start-Process -WindowStyle Minimized powershell -ArgumentList "\\DellGenericFileServer01\Shares\Applications\_BaselineAppInstaller\scripts\Upate-Help.ps1"
Start-Job -FilePath "\\DellGenericFileServer01\Shares\Applications\_BaselineAppInstaller\scripts\Upate-Help.ps1"

Clear-Host

# Process HU Configs
# Update-Help -Force -ErrorAction SilentlyContinue
dism /online /enable-feature /featurename:telnetclient /NoRestart
# Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction SilentlyContinue
foreach ($iptreg in $regFiles) {reg import $configLoc\$iptreg}
netsh advfirewall import $configLoc\huBaselineFWRules.wfw
winrm quickconfig -quiet -force


Clear-Host

# Enable SMB 1.0 client only.  Have to remove SMB 1.0 server separately
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-client -All -NoRestart -ErrorAction SilentlyContinue
disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-server -NoRestart -ErrorAction SilentlyContinue


Clear-Host

# Create necessary custom directories
mkdir $env:SystemDrive\Temp -ErrorAction SilentlyContinue
mkdir $wallPaperDir\higheredinstitutionnameU -ErrorAction SilentlyContinue
mkdir $userAccPics\OEM -ErrorAction SilentlyContinue
mkdir $env:ProgramData\higheredinstitutionnameU -ErrorAction SilentlyContinue


Clear-Host

# Copy HU custom Files
Copy-Item $configLoc\UpdateChangeLog.txt $env:systemdrive\ -ErrorAction SilentlyContinue
Copy-Item $configLoc\$huWallpaper $wallPaperDir\higheredinstitutionnameU -ErrorAction SilentlyContinue
Copy-Item $userAccPics\*.* $userAccPics\OEM -ErrorAction SilentlyContinue
Copy-Item $configLoc\UserAccountPictures\*.* $userAccPics\ -ErrorAction SilentlyContinue
Copy-Item $configLoc\"Internet Explorer.lnk" $env:ProgramData\"Microsoft\Windows\Start Menu\Programs"


Clear-Host

# Add HUCITCC local users
New-LocalUser -Name $localUsr -Password $pass -PasswordNeverExpires -Description $localUsrDesc -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "administrators" -Member $localUsr -ErrorAction SilentlyContinue
New-LocalUser -Name $localUsr2 -Password $pass2 -PasswordNeverExpires -Description $localUsrDesc -ErrorAction SilentlyContinue
Add-LocalGroupMember -Group "administrators" -Member $localUsr2 -ErrorAction SilentlyContinue


Clear-Host

# Install applications from config files
# Check for the installation of Office 2016.
# $off201632bitInst=(Test-Path "C:\Program Files (x86)\Microsoft Office\Office16\WINWORD.EXE")
$off201664bitInst=(Test-Path "C:\Program Files\Microsoft Office\Office16\WINWORD.EXE")
$off201664bitVisioInst=(Test-Path "C:\Program Files\Microsoft Office\Office16\VISIO.EXE")
$off201664bitProjInst=(Test-Path "C:\Program Files\Microsoft Office\Office16\WINPROJ.EXE")

if ($off201664bitInst) {
    #Write-Host "Office 2016 64bit installed. Skipping."
    #$counter=1
}
if ($off201664bitVisioInst -eq $off201664bitProjInst) {
    #Write-Host "Visio 2016 and Project 2016 64bit installed. Skipping."
    # Default to 0 for now until I code more robust conditional statements
    # $counter=2
}
if ($off201664bitInst -eq $off201664bitVisioInst -eq $off201664bitProjInst) {
    #Write-Host "Entire Office 2016 suite installed!  Skipping."
    # Default to 0 for now until I code more robust conditional statements
    # $counter=3
}

switch ($counter) {
    0 {$allAppsToInstall="AppsToInstall_MSFTOfficeProfPro.txt","AppsToInstall_MSFTOfficeProjectVisio.txt","AppsToInstall_MSFTOtherApps.txt","AppsToInstall_ThirdParty.txt"}
    1 {$allAppsToInstall="AppsToInstall_MSFTOfficeProjectVisio.txt","AppsToInstall_MSFTOtherApps.txt","AppsToInstall_ThirdParty.txt"}
    2 {$allAppsToInstall="AppsToInstall_MSFTOtherApps.txt","AppsToInstall_ThirdParty.txt"}
    3 {$allAppsToInstall="AppsToInstall_MSFTOtherApps.txt","AppsToInstall_ThirdParty.txt"}
}

foreach ($curAppsListToInstall in $allAppsToInstall) {
    $appsToInstall=Import-Csv $configLoc\$curAppsListToInstall
    foreach ($appToInst in $appsToInstall) {
        Write-Host $appToInst.name $appToInst.arg
        Start-Process -FilePath $appToInst.name -ArgumentList $appToInst.arg -Wait -PassThru -WorkingDirectory $appInstBaseDir
        }
}


Clear-Host

# Install Alertus, has to be from local path
Copy-Item -Recurse $appInstBaseDir\Apps\PC-Config $env:SystemDrive\Temp
Start-Process -FilePath $env:SystemDrive\Temp\PC-Config\alertus-desktopAlert_DotNet4.5_v5.1.33.0.msi -ArgumentList /qb -Wait -PassThru
Start-Sleep -s 1


# Dot source script to check for and install Acrobat Pro 11 11.0.23 patch
. \\DellGenericFileServer01\Shares\Applications\_BaselineAppInstaller\scripts\UpdateAdobeAcrobat11Pro.ps1


Clear-Host

# Dot source script to check for and install Symantec Endpoint Protection 14, latest version
. \\DellGenericFileServer01\Shares\Applications\_BaselineAppInstaller\scripts\CheckAndUpdateSEP14.ps1
# Write-Host "**** Installing Symantec Endpoint 14 Protection client.  Please be patient. ****"
# Write-Host ".."
# Start-Process -FilePath "\\DellGenericFileServer01\Shares\Symantec Endpoint\Symantec Endpoint 14\LatestVersion\setup.exe" -Wait -PassThru


Clear-Host

# Import LGPO Settings and default Start Layout
Start-Process -FilePath $appInstBaseDir\LGPO\LGPO.exe -ArgumentList "/g $configLoc\LocalGroupPolicy"
# Import-StartLayout -MountPath $env:SystemDrive\ -LayoutPath $configLoc\hubaselineinstall_v03.xml
Import-StartLayout -MountPath $env:SystemDrive\ -LayoutPath $configLoc\huStartMenu_v04.xml


Clear-Host

# Kill java upater
Stop-Process -Name jusched* -Force
Start-Sleep -s 2


Clear-Host

# Delete unecessary items, remove JAVA auto-update binaries, cleanup
Remove-Item $userAccPics\*.dat -Force -ErrorAction SilentlyContinue
Remove-Item ${env:CommonProgramFiles(x86)}\Java -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $env:SystemDrive\Temp\PC-Config -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $env:SystemDrive\Users\Public\Desktop\*.lnk -ErrorAction SilentlyContinue


# CD (set-location) back to system drive
Set-Location $env:SystemDrive

# Start update process
# Start-Process ms-settings:windowsupdate-action


Clear-Host

<# 

    Change SKU from PRO to Enterprise or Education by entering the appropriate product key
    Disabled for now

    changepk.exe /ProductKey <enter your new product key here>

#>

# Prompt to restart
# [System.Windows.MessageBox]::Show($notificationText,$messageBoxTitle)

Write-Host $dots

# Read-Host -Prompt $notificationText
Write-Host $notificationText


shutdown -t 60 -r -f