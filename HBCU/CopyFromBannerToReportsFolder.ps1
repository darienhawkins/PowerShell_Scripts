# Important information obfuscated (hostname, IP address, username, password, etc)

<#
    Auth:       Hawkins, Darien H
                Director, Computer Center
    Purpose:    Copy files from ERPApplication DB server via scp to designated folders

    |--------------|---------|----------------------------------------------------
    |     Date     | Version | Action
    |--------------|---------|----------------------------------------------------
    | Jul 09, 2020 |  1.0.0  | Initial script
    |--------------|---------|----------------------------------------------------
#>

# Clear screen and define variables
Clear-Host
$unixUser="unixUser01"
$sourcePath="192.123.123.123:/s16/sct/unixUser01/PROD"
$destPath="\\fileserver01\reports$\Clearinghouse"
$destPath2="\\fileserver01\reports$\Registrar"
$destPath3="\\fileserver01\ERPApplication Reports\REG\ClearingHouse"
$filePrefix="sfrnslc_"
$userInput=Read-Host "Enter number here "

# Copy via scp from ERPApplication DB server to reports share folders
scp $unixUser@$sourcePath/$filePrefix$userInput* $destPath

# Copy the files to the two other locations
Copy-Item $destPath\$filePrefix$userInput* $destPath2 -PassThru
Copy-Item $destPath\$filePrefix$userInput* $destPath3 -PassThru

# Send email once done as a notification
Send-MailMessage `
    -SmtpServer 123.234.123.234 `
    -From "MoveToClearingHouseRequest@noreply.higheredinstitutionnameU.edu" `
    -Subject "ERPApplication Jobs Request - Clearinghouse File Move" `
    -To ERPApplicationjobs@higheredinstitutionnameU.edu `
    -Body "$filePrefix$userInput have been copied to locations $destPath, $destPath2, and $destPath3.  If file is not found, please contact ERPApplicationjobs@higheredinstitutionnameU.edu"
