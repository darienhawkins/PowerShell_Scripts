# Important information obfuscated (hostname, IP address, username, password, etc)

# *****************************************************************************
#    Rename student-ad-import.csv and student-ad-import.txt files and add
#    date and time stamp. Move renamed files to "old" folder
#    Updated; 18 June 2018, Darien Hawkins
#    Version 1
# *****************************************************************************


# ************ DECLARE VARIABLES **********************************************
$curLocation="\\fileserver02\Temp_Shares\Student_Imports"
$oldFolder="old"
$nameOfFile="student-ad-import"
$dateStamp=Get-Date -UFormat "%Y%M%d@%H%M%S"

# ************ TEST FOR EXISTENCE, RENAME FILE ********************************
if (Test-Path $curLocation\$nameOfFile.csv) {
    Rename-Item $curLocation\$nameOfFile.csv $curLocation\$nameOfFile"_"$dateStamp.csv
    Rename-Item $curLocation\$nameOfFile.txt $curLocation\$nameOfFile"_"$dateStamp.txt
    Move-Item $curLocation\$nameOfFile"_"$dateStamp.* $curLocation\$oldFolder
    ###########################################
    # Create new files for continued testing
    # Move or comment out for production
    #
    # New-Item -ItemType File $curLocation\$nameOfFile.csv
    # New-Item -ItemType File $curLocation\$nameOfFile.txt
    #
    ###########################################
} else {
    Clear-Host
    Write-Host "File not found"
}
# ************ SLEEP FOR 1 SECOND PRIOR TO SCRIPT TERMINATION *****************
start-sleep -s 1


