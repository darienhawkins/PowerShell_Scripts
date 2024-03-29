clear-host
# Important information obfuscated (hostname, IP address, username, password, etc)

###################################################################################
#
#  Process casheringApp1 files
#  Written by Darien Hawkins, Director
#  Version 1.0
#
#  This file is to run on the same day as when the remit files are generated.
#  Set schedule to run at 9:00PM.
#
#--------------------------------------------------------------------------------
#     Date     | seq |  Description
#  ------------|-----|-------------------------------------------------------------
#  01 Sep 2020 | 003 | Added code to parse file and check for existence | DH
#  ------------|-----|-------------------------------------------------------------
#  31 Aug 2020 | 002 | Fix timing and file copy location | DH
#  ------------|-----|-------------------------------------------------------------
#  28 Aug 2020 | 001 | Initial Draft  | Darien Hawkins (DH)
#  --------------------------------------------------------------------------------
#
#
###################################################################################

# Define variables, establish environment

$serverBase="\\DellGenericFileServer01\systems"
$uncPath="$serverBase\ERPApplicationProd\touchnet\casheringApp1"
$sendMailFolder="$serverBase\_Tools\SendEmail"
$winscpPath="$serverBase\_Tools\WinSCP"
$scriptFolder="scripts"
$archiveFolder="archive"
$winSCPArg="getchashnet_ftps.txt"
$appworXTarget="\\oldschedserver01\Appworx$\Prod\ARStudent"
$todaysDate=(Get-date -Format yyyyMMdd)
$thisYear=(Get-date -Format yyyy)
$destFileNme="TYRSPAY.dat"
$archive1="$serverBase\ERPApplicationProd\AR-Student\Datafiles\casheringApp1\$thisYear"


#Invoke commandline WinSCP and call script file
Start-Process -wait $winscpPath\winscp.com -ArgumentList "/script=$uncPath\$scriptFolder\$winSCPArg"


#Copy file to archive folders and provide time for download to complete
Start-Sleep 5
Copy-Item $uncPath\recon.remit_* $uncPath\$archiveFolder
Copy-Item $uncPath\recon.remit_* $archive1
Copy-Item $uncPath\recon.remit_* $appworXTarget


# Test for existance and copy file based on today's date to proper name for AppWorX processing
if (Test-Path $appworXTarget\*$todaysDate*) {
    # If file is found, copy to TYRSPAY.dat
    Copy-Item $appworXTarget\*$todaysDate* $appworXTarget\$destFileNme
    } else {
    # If file is not found, exit script
    Exit
    }


# Read last line of file to send via email
$lastLine=(Get-Content $appworXTarget\*$todaysDate* -Tail 1)


#===========================================================================

# Send email
$fileNameOnly=(Get-ChildItem $appworXTarget\*$todaysDate* -Name).ToString()
$msgEmailServer="aaa.bbb.ccc.ddd"
$msgMessage="casheringApp1 file $fileNameOnly retrieved from eft.casheringApp1.com, renamed to $destFileNme, and placed for processing."
$msgSubject="casheringApp1 File $fileNameOnly Retrieved"
$msgRecipients="ERPApplicationjobs@higheredinstitutiondomain.edu,person1@higheredinstitutiondomain.edu"
$msgFrom="casheringApp1ProcessAck-DoNotReply@higheredinstitutiondomain.edu"
$msgArgs="-s $msgEmailServer -m $msgMessage -u $msgSubject -t $msgRecipients -f $msgFrom"
Start-Process -FilePath $sendMailFolder\sendEmail.exe -ArgumentList $msgArgs -WindowStyle Minimized

Start-Sleep 3

# Reassign only necessary sendmail variables
$msgMessage=$lastLine
$msgSubject="casheringApp1 Processing Information for File $fileNameOnly "
$msgRecipients="person4@higheredinstitutiondomain.edu,person2@higheredinstitutiondomain.edu,person1@higheredinstitutiondomain.edu"
$msgArgs="-s $msgEmailServer -m $msgMessage -u $msgSubject -t $msgRecipients -f $msgFrom"
Start-Process -FilePath $sendMailFolder\sendEmail.exe -ArgumentList $msgArgs -WindowStyle Minimized


#===========================================================================

# Clear screen and wait about 3 seconds.
clear-host
Start-Sleep 3


#Delete files from folder
Remove-Item $appworXTarget\recon.remit_*
Remove-Item $uncPath\recon.remit_*