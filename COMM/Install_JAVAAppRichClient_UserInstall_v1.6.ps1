<#
###############################################################################

  Date Created:     09 Jul 2021
  Date Modified:    16 Jul 2021
  Version:          1.6
  File Name:        Install_JAVAAppRichClient_UserInstall_v1.6.ps1
  Authored By:      Darien Hawkins (IT xxxx)
                    darien.hawkins@CompanyX.com
  Company:          CompanyX
  Department:       BBBXNA IT Dpt
  Purpose:          To programmatically install and configure JAVAApp Rich Client

###############  Update History  ##############################################
   Date     | Seq |  Action
------------|-----|------------------------------------------------------------
16 Jul 2021 | 006 | Set source path to the actual installation server
------------|-----|------------------------------------------------------------
16 Jul 2021 | 005 | Added logic for "admin" install type, added additional shortcut
------------|-----|------------------------------------------------------------
14 Jul 2021 | 004 | Removed archive, takes into account OneDrive Commercial
------------|-----|------------------------------------------------------------
13 Jul 2021 | 003 | Recoded to allow standard user install w/out admin interference
------------|-----|------------------------------------------------------------
13 Jul 2021 | 002 | Added significant code, almost complete
------------|-----|------------------------------------------------------------
09 Jul 2021 | 001 | Initial draft
------------|-----|------------------------------------------------------------
###############################################################################

-------------------------------------------------------------------------------

NOTES:

The file "de.docufy.javaappexecutable.ui.prefs" is what sets the CMS host to lissvJAVAAppmin21.CompanyX.i
On a new install, the file is not present.
Once the change is made in the GUI, the file is then created in the folder
    C:\<InstallLocation>\workspace\.metadata\.plugins\org.eclipse.core.runtime\.settings
We can now copy this preset "de.docufy.javaappexecutable.ui.prefs" file to other destination, thus
eliminating the need to manually set after each install.

Since the application will be distributed in "portable mode,"
standard users can install into their own Windows Profile.  The path is
    C:\users\<username>\JAVAApp-RichClient

The preconfigured shortcut will also be copied to the user's desktop.

When the application is installed in "admin" mode, it will be installed for all user
in a similar manner as most other applications under the folder C:\Program files\CompanyX\JAVAApp-RichClient


-------------------------------------------------------------------------------
#>

# Declare and initialize global script variables
[string]$sourceDir="\\server\servershare\Software\JAVAApp Client" #actual location
#[string]$sourceDir="C:\apps\JAVAApp Client" #For testing
# [string]$sourceArchive="$sourceDir\Archive"
[string]$clientDestinationDir="JAVAApp-RichClient"
[string]$thisDate=(get-date -Format yyyyMMdd)

# checks for the "InstallType."  When the variable is set to "user," the end-user can do his or her
# own installation without the interference of a local administrator.  When set to "admin," an admin with elevated
#   rights will install for all users on the system.

function CheckForPermissions ()
{
    [string]$testFileToCreate="C:\Program Files\TestOfPermissions"
    [bool]$didThisHappen=Test-Path (New-Item -ItemType File $testFileToCreate -ErrorAction SilentlyContinue)
    Clear-Host
    if ($didThisHappen)
    {
        Remove-Item $testFileToCreate
        [string]$global:InstallType=Read-Host "Do you want to install the JAVAApp Rich Client as a 'user' or as an 'admin'?"
    } else
    {
        [string]$global:InstallType="user"
    }
    CheckInstallType
}

# Check to see if a user has admin rights.  If so, the user will be prompted for a type of installation.
# If the user is a standard user, the script will default to "user."
function CheckInstallType ()
{
    if ($InstallType -eq "user")
    {
        [string]$global:CompanyXProgramDataBaseDir=$env:USERPROFILE
    } elseif ($InstallType -eq "admin") {
        [string]$global:CompanyXProgramDataBaseDir="C:\Program files\CompanyX"
        # Check to see if directory is present.  If not, create it
        [bool]$isCompanyXProgramDataBaseDirThere=Test-Path $CompanyXProgramDataBaseDir
        if (!$isCompanyXProgramDataBaseDirThere)
        {
            New-Item -ItemType Directory $CompanyXProgramDataBaseDir
        }
    } else {
        Clear-Host
        Write-Host "Cannot install. Wrong InstallType defined. InstallType must be either 'user' or 'admin'. Exiting."
        break
    }    
}

# Copys the "de.docufy.javaappexecutable.ui.prefs" file, which is what sets the CMS host to lissvJAVAAppmin21.CompanyX.i
# The reference "de.docufy.javaappexecutable.ui.prefs" file to be copied must be located in the source directory indicated
# by the string variable $sourceDir.
function CopyjavaappexecutablePrefsFile ()
{
    [string]$prefFileLocation="$CompanyXProgramDataBaseDir\$clientDestinationDir\workspace\.metadata\.plugins\org.eclipse.core.runtime\.settings"
    [string]$prefFileName="de.docufy.javaappexecutable.ui.prefs"
    Copy-Item $sourceDir\$prefFileName $prefFileLocation
}

# Checks the source location of the zip file.  If found, extracts and calls the function to copy the prefs file to the
# install location, thus nullifying the need to configure following each install.
# If no zip file is found, the script will notify the user and terminate.
# At a later time, we will implement the automatic archive of the zip. For now, that will be a manual process.
function CheckForZipFileAndExapandToDestination ()
{
    if ((Get-Item $sourceDir\*.zip).Exists) 
    {
        # Get zip file name and expand to destination
        [string]$zipFileFullName=(Get-Item $sourceDir\*.zip).FullName
        [string]$zipFileName=(Get-Item $sourceDir\*.zip).Name
        Expand-Archive $zipFileFullName $CompanyXProgramDataBaseDir\
        # Rename extracted folder to "standardized" install location
        [string]$expandedFolder=(Get-ChildItem -Directory $CompanyXProgramDataBaseDir\Lir*distribution).FullName
        Rename-Item $expandedFolder $CompanyXProgramDataBaseDir\$clientDestinationDir
        # Create a blank file with the name of the currently installed version for reference
        [string]$fileVersionToWrite=$zipFileName.Substring(0,$zipFileName.Length-4)
        New-Item -ItemType File -Path $CompanyXProgramDataBaseDir\$clientDestinationDir\$fileVersionToWrite
        # Move Zip file to Archive Folder (do not implement yet)
        # Move-Item -Path $zipFileFullName -Destination $sourceArchive
    } else {
        Clear-Host
        Write-Host "No zip file in source location. Terminating script."
        break 
    }
    CopyjavaappexecutablePrefsFile
}

# Backs up the current configuration.  We only keep one version behind.
function BackupCurrentVersion ()
{
    [string]$clientFileName="javaappexecutable.exe"
    [bool]$isFileThere=(test-path $CompanyXProgramDataBaseDir\$clientDestinationDir\$clientFileName)
    if ($isFileThere)
    {
        Rename-Item $CompanyXProgramDataBaseDir\$clientDestinationDir $CompanyXProgramDataBaseDir\$clientDestinationDir"_bkup-"$thisDate
    }
    CheckForZipFileAndExapandToDestination
}

# If an existing backup is found, that is deleted in favor of a new backup of the version being replaced
function DeleteOldBackup ()
{
    [string]$bkupOld=(Get-Item $CompanyXProgramDataBaseDir\*bkup*).FullName
    [string]$bkupWithCurrDate="$CompanyXProgramDataBaseDir\$clientDestinationDir'_bkup-'$thisDate"
    if ($bkupOld)
    {
        if ($bkupOld -ne $bkupWithCurrDate)
        {
            Remove-Item -Recurse $bkupOld
        }
    }
    BackupCurrentVersion
}

# Creates the user shortcut with the necessary "-nl en" argument in the target path.
# If the user is using One Drive Commercial, the shortcut will be placed accordingly
# If the user is not using One Drive, then the shortcut will go to the user's normal Desktop folder
# The reference "JAVAApp_RichClient.lnk" file to be copied must be located in the source directory indicated
# by the string variable $sourceDir.
function createJAVAAppShortcut ()
{
    [string]$shortcutFileName="JAVAApp_RichClient.lnk"
    if ($InstallType -eq "user")
    {
        if ($env:OneDriveCommercial)
        {
            Copy-Item $sourceDir\$shortcutFileName $env:OneDriveCommercial\Desktop -Force
        } else {
            Copy-Item $sourceDir\$shortcutFileName $env:USERPROFILE\Desktop -Force
        }
    } elseif ($InstallType -eq "admin") {
        [string]$publicshortcutFileName="JAVAApp_RichClient_PublicDesktop.lnk"
        #JAVAApp_RichClient_PublicDesktop
        [string]$publicUserDesktopFolder="C:\Users\public\Desktop"
        Copy-Item $sourceDir\$publicshortcutFileName $publicUserDesktopFolder -Force
        SetACLonLockFile
    }    
}

# Set ACL on the lockfile to "full control" for users.  Only this file is required for the application to run
#   when installed for all users
function SetACLonLockFile ()
{
    [string]$lockFilePath="$CompanyXProgramDataBaseDir\$clientDestinationDir\workspace\.metadata\.lock"
    $NewAcl = Get-Acl -Path $lockFilePath
    [string]$identity = "BUILTIN\users"
    [string]$fileSystemRights = "FullControl"
    [string]$type = "Allow"
    # Create new rule
    $fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
    $fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
    # Apply new rule
    $NewAcl.SetAccessRule($fileSystemAccessRule)
    Set-Acl -Path $lockFilePath -AclObject $NewAcl
}

# The "Main" function whose only purpose is to call the other functions.
function Main ()
{
    CheckForPermissions
    DeleteOldBackup
    createJAVAAppShortcut
}

# Start script
Main