<#
###############################################################################
  For Windows Vista and later OS
  Date Modified: 10 Dec 2019
  Version: 5.4
  Scripted By: Darien Hawkins

 20191210:  Added code to check for valid computer and user name prior
            to performing backup operation
 20191205:  Modified to prompt for computer name and user name to allow an
            admin to remotly run backup script from admin's computer
 20191205:  Added code to send an email message to CC and Help desk staff
            when script is completed
 20191029:  Modifed to different server, genericserver
            Replaced /zb with /b for performance
 20180627:  Added functionality to auto create folder and set permissions
            Can call script and provide -user parameter for usrsname
###############################################################################

#>

<#
param (
    [Parameter(Mandatory=$true)][string]$user
)

# Removes unwanted charaters from passed parameter $user
if ($user -like ".\*") {
    $user="$user".Trim(".","\")
}
#>

Clear-Host

#Ensure computer is online and reachable
function checkComputerStatus {
    Clear-Host
    $cmpName=Read-Host "Enter remote computer name or IP address.  Otherwise, if on the local computer, hit <enter>"
    # Ensure admin want's local computer and did not make a mistake
    if ($cmpName -like "")  {
        $cmpName=$env:COMPUTERNAME
        $ruSure=Read-Host "Are you sure you want to select the local computer $cmpName (y/n)?"
        # Lower and upper case "y" will work.  All other characters equates to "no"
        if (($ruSure -like "y") -or ($ruSure -like "Y")) {
            Write-Host "Contining on local computer $cmpName."
        } else {
            checkComputerStatus
        }
    }
    # Cast local variable to one that is scoped to entire scipt
    Set-Variable -Scope script -Name srcComputerName -Value $cmpName
    Write-Host "Please wait while the script checks to see if $srcComputerName is online and reachable. This process can take as long as 30 seconds."
    
    # If path check is successful contine, otherwise prompt to try again
    if (Test-Path \\$srcComputerName\c$) {
        Clear-Host
        Write-Host "Computer $srcComputerName is online and reachable."
        Write-Host "Here is the user directory listing on $srcComputerName."
    } else {
        Clear-Host
        Write-Host "It seems that $srcComputerName is either not powered on or is not reachable."
        $tryAgain=Read-Host "Do you want to try again and enter another computer name or IP address? (y/n)"
        # Lower and upper case "y" will work.  All other characters equates to "no"
        if (($tryAgain -like "y") -or ($tryAgain -like "Y")) {
            checkComputerStatus
        } else {
            Exit
        }
    }
}
checkComputerStatus

# Prompt for necessary information and declare script scope variables
$copyfromcomputer="yes"
$baseUNCPath="\\genericfileserver02\UserDataTransfers"
$templateFolder="_scripts\PermissionTemplateFolder"
$normalLocalUserDir="\\$srcComputerName\c$\users"
$destOutlookPSTFolder="Documents\Outlook_PST_Files"
$defaultOutlookPSTFolder="AppData\Local\Microsoft\Outlook"

# List users on target computer and prompt for username
Get-ChildItem $normalLocalUserDir

# Check for valid user name
function getTestUserName {
    $askName=Read-Host "On computer $srcComputerName, enter user's username"
    IF (Test-Path $normalLocalUserDir\$askName) {
        Set-Variable -Scope script -Name usrsname -Value $askName
        Write-Host "starting . . . ."
    } else {
        Clear-Host
        Get-ChildItem $normalLocalUserDir
        Write-Host "It appears that $askName is not a valid username on computer $srcComputerName. Please try again."
        getTestUserName
    }
}
getTestUserName



# Sendmail scope variables
$u_sub="Backup Script Stutus for user: $usrsname"
$f_adr="userbackupscript@emaildomain.edu"
$t_rec="emailadmin@emaildomain.edu CITHelpDeskStaff@emaildomain.edu"
$s_svr="aaa.bbb.ccc.45:25"


#  Defines functions

function sendEmailNotification () {
    # Send message to notify completion
    $completeDatetime=(get-date).DateTime
    $m_msg="Backup script for $usrsname started at $startDatetime and completed at $completeDatetime."
    Invoke-Command -ScriptBlock {\\genericfileserver02\UserDataTransfers\_scripts\_SendEmail\sendEmail.exe -u $u_sub -f $f_adr -t $t_rec -s $s_svr -m $m_msg}
    Return
}

function CopyTheFiles() {
    $fldrarray=Get-ChildItem -Path $uncsrcpath -Name
    foreach($fldr in $fldrarray) {
        $cpsrc="$uncsrcpath\$fldr"
        $cpdes="$uncdespath\$fldr"
        if ($copyfromcomputer -eq "yes" ) {
            robocopy /e /r:0 /w:0 /b $cpsrc $cpdes
        } else {
            robocopy /e /r:0 /w:0 $cpsrc $cpdes
        }
    }
    if ($copyfromcomputer -eq "yes" ) {
        New-Item -ItemType directory -Path "$outostdest"
        robocopy /e /r:0 /w:0 /zb $outostpath $outostdest *.pst
        foreach ($curWMI in "win32_computersystemproduct","win32_computersystem","win32_bios") {
            Get-WmiObject -ComputerName $srcComputerName $curWMI >> "$uncdespath\$srcComputerName.txt"
        }
    }
    sendEmailNotification;
    Return
}
function setACLPermissions () {
    # Check for existence of folder. If folder is not located on server
    # Automatically create the folder on the share and properly set permissions
    if (!(Test-Path -Path $baseUNCPath\Users\$usrsname)) {
        New-Item -ItemType Directory $baseUNCPath\Users\$usrsname
        $egACL="$baseUNCPath\$templateFolder"
        $acl=Get-Acl $egACL
        $ar1=New-Object System.Security.AccessControl.FileSystemAccessRule("childdomain\computer center administrators","fullcontrol","containerinherit,objectinherit","none","allow")
        $ar2=New-Object System.Security.AccessControl.FileSystemAccessRule("childdomain\$usrsname","fullcontrol","containerinherit,objectinherit","none","allow")
        $acl.AddAccessRule($ar1)
        $acl.AddAccessRule($ar2)
        Set-Acl $baseUNCPath\Users\$usrsname $acl
    }
    Return
}

if ($copyfromcomputer -eq "yes" ) {
    # Copy from old computer to server by an admin
    $startDatetime=(get-date).DateTime
    $uncsrcpath="$normalLocalUserDir\$usrsname"
    $uncdespath="$baseUNCPath\Users\$usrsname"
    $outostpath="$uncsrcpath\$defaultOutlookPSTFolder"
    $outostdest="$uncdespath\$destOutlookPSTFolder"
    setACLPermissions;
    CopyTheFiles;
}

if ($copyfromcomputer -eq "no" ) {
    # Copy to new computer by customer/end-user
    $uncsrcpath="$baseUNCPath\Users\$usrsname"
    $uncdespath="$normalLocalUserDir\$usrsname"
    CopyTheFiles;
}
