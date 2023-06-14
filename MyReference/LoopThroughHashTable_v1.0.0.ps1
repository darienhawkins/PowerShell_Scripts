<##############################################################################

Date Created:       14 Jun 2023
Date Modified:      14 Jun 2023
Version:            1.0.0
Author:             Darien Hawkins (darien-hawkins@hotmail.com)
Description:        Copy and run files using a hash table array;
                    no need to read from an input file

###############  Update History  ##############################################
    Date    |  ver  |  Notes
------------|-------|----------------------------------------------------------
14 Jun 2023 | 1.0.0 | Initial draft
------------|-----  |----------------------------------------------------------
##############################################################################>


# vs_Community.exe --allWorkloads --includeRecommended --passive --norestart 
# vs_Community.exe --all --passive --norestart 
# https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2022

Clear-Host


# Set source/destination location variables
$netSourcePath="\\localhost\c$\Apps"
$localDestFolder="c:\apps"

# Define array
$dataSourceArray=(
    @{SourcePath="$netSourcePath\Folder1 with spaces";DestPath="$localDestFolder\folder1nospaces";exec="cmd";arg="install.cmd"},
    @{SourcePath="$netSourcePath\Folder1 with spaces";DestPath="$localDestFolder\folder1nospaces";exec="VC_redist.x64.exe";arg="/passive /norestart"},
    @{SourcePath="$netSourcePath\Folder4 with spaces";DestPath="$localDestFolder\folder1nospaces";exec="VC_redist.x86.exe";arg="/passive /norestart"},
    @{SourcePath="$netSourcePath\Folder2 with spaces";DestPath="$localDestFolder\folder2nospaces";exec="dotnet-sdk-6.0.410-win-x64.exe";arg="/passive /norestart"},
    @{SourcePath="$netSourcePath\Folder3 with spaces";DestPath="$localDestFolder\folder2nospaces";exec="7z2201-x64.exe";arg=" "}
)

# loop through each
foreach ($appToInstall in $dataSourceArray) {
    # Copy files from source to local destination
    Robocopy.exe $appToInstall.SourcePath $appToInstall.DestPath /e /r:1 /w:1
    # Handle special condition where install is a batch/cmd file
    if ($appToInstall.exec -eq "cmd") {
        $src="cmd"
        $procArg="/c", $appToInstall.arg
    } else {
        $src=$appToInstall.DestPath+"\"+$appToInstall.exec
        $procArg=$appToInstall.arg
    }
    # Do installaiton following file copy operation
    Start-Process $src -ArgumentList $procArg -Wait
}