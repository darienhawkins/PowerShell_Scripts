<#
###############################################################################

  Date Created:     28 Jun 2021
  Date Modified:    20 Ju7 2021
  Version:          1.5
  File Name:        InstallXMDDanalyze_v1.4.ps1
  Authored By:      Darien Hawkins (IT xxxx)
                    darien.hawkins@CompanyX.com
  Company:          CompanyX
  Department:       BBBXNA IT Dpt
  Purpose:          To programmatically install XMDD analyze Service

###############  Update History  ##############################################
   Date     | Seq |  Action
------------|-----|------------------------------------------------------------
20 Jul 2021 | 005 | For now, have to do a manual uninstall, changed uninstalXMDDanalyzeservice
            |     | function to open appwiz.cpl and await for further input
------------|-----|------------------------------------------------------------
14 Jul 2021 | 004 | Fixed issue with "new" install not starting service.
------------|-----|------------------------------------------------------------
14 Jul 2021 | 003 | Set service recovery options to automatically restart
------------|-----|------------------------------------------------------------
14 Jul 2021 | 002 | Refactored, set proper source location, added comments.
------------|-----|------------------------------------------------------------
28 Jun 2021 | 001 | Initial draft
------------|-----|------------------------------------------------------------
###############################################################################
#>

# Declare and initialize global script variables
[string]$XMDDAppName="CompanyX (DivX) digging Data analyze Service XMDD"
[string]$XMDDServiceName="CompanyX (DivX) digging Data analyze Service"
[string]$XMDDConfigPath="C:\Program Files\CompanyX\CompanyX (DivX) digging Data analyze Service"
[string]$XMDDConfigFile="analyze.service.exe.config"
[string]$webConfigFile="web.config"
[string]$XMDDConfigBkupBasePath="C:\apps"
[string]$XMDDConfigBkupSubFolder="bkup-"+(Get-Date -Format yyyyMMdd)
###############################################################################
# Real location in STAGING AND PROD
[string]$XMDDInstallaerLocation="D:\Install\DTML analyze\Installers"
[string]$XMDDInstallFileName="CompanyX DivX digging Data analyze Service.msi"
###############################################################################
[string]$servciesmsc="C:\Windows\System32\services.msc"

# Backup up current analyze.service.exe.config file, get hash and compare.
function backupRestoreCurrentConfig
{
    param
    (
        # Passed param flag to indicate backup or restore. If "B" backup, if "R" restore
        [string]$ParamBackupOrRestoreFlag
    )
    if (Test-Path $XMDDConfigPath\$XMDDConfigFile)
    {
        if ($ParamBackupOrRestoreFlag -eq "B")
        {
            [string]$global:XMDDConfigHash=(Get-FileHash $XMDDConfigPath\$XMDDConfigFile).hash
            Write-Host "Backing up current '$XMDDConfigFile' configuration file."
            New-Item -ItemType Directory $XMDDConfigBkupBasePath\$XMDDConfigBkupSubFolder -ErrorAction SilentlyContinue -InformationAction SilentlyContinue
            Copy-Item $XMDDConfigPath\$XMDDConfigFile $XMDDConfigBkupBasePath\$XMDDConfigBkupSubFolder\$XMDDConfigFile -Force
            [string]$bkupHash=(Get-FileHash $XMDDConfigBkupBasePath\$XMDDConfigBkupSubFolder\$XMDDConfigFile).hash
            if ($bkupHash -eq $XMDDConfigHash)
            {
                return
            } else {
                Write-Host "**** Hashes don't match. ****"
                Read-Host
                # break
            }
        } elseif ($ParamBackupOrRestoreFlag -eq "R") {
            Write-Host "Restoring '$XMDDConfigFile' configuration to new installed version."
            Copy-Item $XMDDConfigBkupBasePath\$XMDDConfigBkupSubFolder\$XMDDConfigFile $XMDDConfigPath\$XMDDConfigFile -Force
            [string]$bkupHash=(Get-FileHash $XMDDConfigBkupBasePath\$XMDDConfigBkupSubFolder\$XMDDConfigFile).hash
            [string]$restoreHash=(Get-FileHash $XMDDConfigPath\$XMDDConfigFile).hash
            if (($restoreHash -eq $bkupHash) -and ($restoreHash -eq $XMDDConfigHash))
            {
                Write-Host "All hashes for '$XMDDConfigFile' match.  We are golden."  
            } else {
                Write-Host "What gives"
                Pause
            }
        }
    } else {
        Write-Host "XMDD analyze Service not installed.  Installing for first time."
        installXMDDanalyzeService("F")
    }
    SetServiceRestartOptions($XMDDServiceName)
}

# When called, this function will decrypt the analyze.service.exe.config file.
# Otherwise, it is not needed.
function decrptConfigFile
{
    Copy-Item $XMDDConfigBkupBasePath\$XMDDConfigBkupSubFolder\$XMDDConfigFile $XMDDConfigBkupBasePath\$XMDDConfigBkupSubFolder\$webConfigFile
    [string]$aspnetRegIIS="C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis.exe"
    [string]$aspnetRegIISArgList="-pdf appSettings $XMDDConfigBkupBasePath\$XMDDConfigBkupSubFolder"
    Start-Process -FilePath $aspnetRegIIS -ArgumentList $aspnetRegIISArgList -NoNewWindow
    Read-Host 
}

# Gracefuly stops the running service and uninstalls the application.
function uninstalXMDDanalyzeservice
{
    Write-Host "Stopping the service if running."
    [string]$isRunning=(Get-Service -DisplayName $XMDDServiceName).Status
    if ($isRunning -eq "Running")
    {
        Stop-Service -DisplayName $XMDDServiceName -Force
    }

    ######################################################################### 
    # Does not work properly as of now. Commented out as of version 1.5
    #########################################################################
    # [string]$XMDDApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq $XMDDAppName}
    # [string]$XMDDApp.Uninstall()

    Write-Host "Please manually uninstall current version."
    Start-Process -Wait -FilePath C:\Windows\System32\appwiz.cpl
    [string]$isanalyzeRemovedManually=Read-Host "Is analyze Service removed? (y/n)"
    [string]$XMDDExecutableFile="analyze.service.exe"
    [string]$isExecutableRemoved=(Test-Path $XMDDConfigPath\$XMDDExecutableFile)
    if (($isanalyzeRemovedManually -eq "y") -and ($isExecutableRemoved -eq "False"))
    { 
        return
    } else {
        Write-Host "`
        ##########################################################################`
        XMDD analyze service is not fully uninstalled. Please investigate. Exiting.`
        ##########################################################################`
        "
        break
    }

    # Remove extranious Temp files if they exist
    if (Test-Path $XMDDConfigPath)
    {
        Remove-Item -Recurse $XMDDConfigPath\* -Force
    }
    return
}

# Prompts the user for which version to install.
# Installs selected version and calls the backupRestoreCurrentConfig function
#   with a passed "R" argument to copy back the analyze.service.exe.config file.
# Sets the service startup type to "Automatic."
function installXMDDanalyzeService
{
    param
    (
        [string]$ParamFirstInstall
    )
    (Get-ChildItem $XMDDInstallaerLocation).Name
    Write-Host "Enter version number.  (i.e. 4.0.x)"
    [string]$XMDDanalyzeVerNum=Read-Host
    Write-Host "Installing selected version $XMDDanalyzeVerNum."
    [string]$installPathString="$XMDDInstallaerLocation\$XMDDanalyzeVerNum\$XMDDInstallFileName"
    Start-Process $installPathString -Wait
    if ($ParamFirstInstall -eq "F")
    {
        SetServiceRestartOptions($XMDDServiceName)
        break
    } else {
        backupRestoreCurrentConfig("R")
    }
}

# Set the service Recovery actions to "Restart the Service"
# Have to use the SC.exe from Command prompt.
function SetServiceRestartOptions
{
    param (
        [string]$ParamXMDDServiceName
    )
    Set-Service $ParamXMDDServiceName -StartupType Automatic
    & $env:windir\system32\cmd.exe /c $env:windir\system32\sc.exe failure $ParamXMDDServiceName reset=5 actions=restart/5
    # Start-Service $ParamXMDDServiceName
    Write-Host "Please start service if not already started."
    Write-Host "Feel free to doublecheck the $XMDDConfigFile for accuracy."
    Start-Process $servciesmsc
}


# "Main" function to all other functions
function Main
{
    Clear-Host
    backupRestoreCurrentConfig("B")
    # decrptConfigFile
    uninstalXMDDanalyzeservice
    installXMDDanalyzeService
}

# Start Script
Main