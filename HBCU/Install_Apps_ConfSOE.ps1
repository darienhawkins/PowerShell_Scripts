# Important information obfuscated (hostname, IP address, username, password, etc)

<#
    Auth: Hawkins, Darien H
          Director, Computer Center
    
    |--------------|---------|----------------------------------------------------
    |     Date     | Version | Action
    |--------------|---------|----------------------------------------------------
    | Jul 08, 2020 |  2.1.3  | Updated Altertus Installer msi
    |              |         | Call seperate Adobe font install script
    |--------------|---------|----------------------------------------------------
    | Mar 20, 2020 |  2.1.2  | Reorg code, move SEP to seperate line
    |--------------|---------|----------------------------------------------------
    | Dec 10, 2019 |  2.1.1  | Updated to update to Windows ver.1909
    |--------------|---------|----------------------------------------------------
    | Oct 25, 2019 |  2.1.0  | Added abilit to install fonts, refactored variables
    |--------------|---------|----------------------------------------------------
    | Oct 17, 2019 |  2.0.1  | Updated $upgradeAssistantPath= path
    |--------------|---------|----------------------------------------------------
    
    
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
$appsToInstall=Import-Csv $configLoc\AppsToInstall.txt
$regFiles="DisableSmartScreenTemp.reg","HUOEMReg.reg","enableRDP.reg"
$pass=ConvertTo-SecureString -String $ploc -AsPlainText -Force
$pass2=ConvertTo-SecureString -String $ploc2 -AsPlainText -Force
$localUsr="somelocaladminaccount"
$localUsr2="higheredinstitutionname"
$localUsrDesc="Local account for administering the computer"
$notificationText="Install and configuration complete.  Computer will reboot in 10 seconds. Please run Windows updates and activate Office 2016 following system reboot."
$messageBoxTitle="Configuration Complete/Reboot Notification"
$proceedWithInstall="Proceeding with application install and configuration.  The computer will reboot automatically at completion."
$latestWinVer="1909"
$upgradeAssistantPath=$sourceShare+"\OS_Installs\Win10-Version-Upgrade\setup-$latestWinVer.lnk"
$checkWinVer=[System.Environment]::OSVersion.VersionString
$dots="......................................................................................"

#$fontSourceFolder=$sourceShare+"\Applications\Adobe\AdobeFonts"
#$fontNamespace = 0x14
#$objShell = New-Object -ComObject Shell.Application
#$objFolder = $objShell.Namespace($fontNamespace)
#$fontFolder = "C:\Windows\Fonts"


<# Enable MessageBox class (not used)

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName System.Windows.Forms

#>

# Declare Windows 1909 Update Function
function updateToLatestWindowsVersion {
    Start-Process -FilePath $upgradeAssistantPath
    Start-Sleep -s 15
    exit
    }

# Check to see if current instance is Windows
if ($checkWinVer -like "*18363*") {
    Clear-Host
    echo "Windows is running the latest verson. $proceedWithInstall"
    Start-Sleep -s 5 } else {
    Clear-Host
    echo $dots
    echo "This installation of Windows 10 is not version $latestWinVer."
    echo "It is higly recommened to upgrade now to save time and bandwidth later."
    do {$instAnswer=Read-Host -Prompt "Do you want to run the Windows Upgrade Wizard (recommended)? (y/n)"} 
        until ("y","n" -ccontains $instAnswer)
    if ($instAnswer -eq "y") {
        Clear-Host
        echo $dots
        echo "Will start upgrade process now."
        echo "Be sure to keep both 'Install Windows 10' and 'Keep personal files and apps' options selected."
        echo "The $latestWinVer upgrade can take over an hour to complete.  Please be patient."
        echo "After Windows 10 is upgraded to $latestWinVer, please rerun this script to complete application installs and OS configuration."
        updateToLatestWindowsVersion
        } else {
        echo " " $proceedWithInstall
        Start-Sleep -s 5
        }
    }

# Start installation of Adobe fonts in parallel with this script
Start-Process -WindowStyle Minimized powershell -ArgumentList \\DellGenericFileServer01\Shares\Applications\_BaselineAppInstaller\scripts\InstallAdobeFonts.ps1


Clear-Host

# Process HU Configs
Update-Help -Force -ErrorAction SilentlyContinue
dism /online /enable-feature /featurename:telnetclient /NoRestart
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction SilentlyContinue
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

# Install applications from config file
foreach ($appToInst in $appsToInstall) {
    Write-Host $appToInst.name $appToInst.arg
    Start-Process -FilePath $appToInst.name -ArgumentList $appToInst.arg -Wait -PassThru -WorkingDirectory $appInstBaseDir
    }


Clear-Host

# Import LGPO Settings and default Start Layout
Start-Process -FilePath $appInstBaseDir\LGPO\LGPO.exe -ArgumentList "/g $configLoc\LocalGroupPolicy"
# Import-StartLayout -MountPath $env:SystemDrive\ -LayoutPath $configLoc\hubaselineinstall_v03.xml
Import-StartLayout -MountPath $env:SystemDrive\ -LayoutPath $configLoc\huStartMenu_v04.xml


Clear-Host

# Install Alertus, has to be from local path
Copy-Item -Recurse $appInstBaseDir\Apps\PC-Config $env:SystemDrive\Temp
Start-Process -FilePath $env:SystemDrive\Temp\PC-Config\alertus-desktopAlert_DotNet4.5_v5.1.33.0.msi -ArgumentList /qb -Wait
Start-Sleep -s 1


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


Clear-Host

Write-Host "**** Installing Symantec Endpoint 14 Protection client.  Please be patient. ****"
Write-Host ".."
Start-Process -FilePath "\\DellGenericFileServer01\Shares\Symantec Endpoint\Symantec Endpoint 14\LatestVersion\setup.exe" -Wait -PassThru


# Start Edge to finish configuration
Start-Process -FilePath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"



# CD back to system drive
cd $env:SystemDrive

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

echo $dots

# Read-Host -Prompt $notificationText
Write-Host $notificationText

shutdown -t 20 -r -f