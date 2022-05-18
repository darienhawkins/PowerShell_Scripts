# Important information obfuscated (hostname, IP address, username, password, etc)

<#
###############################################################################
  For Windows Vista and later OS
  Date Modified: 29 Oct 2018
  Version: 5.1
  Scripted By: Darien Hawkins

 20191029: Modifed to different server, SuperMicroGenericFileServer   
 20180627: Added functionality to auto create folder and set permissions
           Can call script and provide -user parameter for usrsname
###############################################################################


param (
    [Parameter(Mandatory=$true)][string]$user
)

# Removes unwanted charaters from passed parameter $user
if ($user -like ".\*") {
    $user="$user".Trim(".","\")
}

#>

# Declare script scope variables
$usrsname=$env:USERNAME
$copyfromcomputer="no"   # "yes" or "no"
$baseUNCPath="\\SuperMicroDellGenericFileServer01\UserDataTransfers"
$templateFolder="_scripts\PermissionTemplateFolder"
$normalLocalUserDir="c:\users"
$destOutlookPSTFolder="Documents\Outlook_PST_Files"
$defaultOutlookPSTFolder="AppData\Local\Microsoft\Outlook"

#  Defines functions
function CopyTheFiles() {
    $fldrarray=Get-ChildItem -Path $uncsrcpath -Name
    foreach($fldr in $fldrarray) {
        $cpsrc="$uncsrcpath\$fldr"
        $cpdes="$uncdespath\$fldr"
        if ($copyfromcomputer -eq "yes" ) {
            wmic csproduct list full >> "$uncdespath\$env:computername.txt"
            wmic computersystem list full >> "$uncdespath\$env:computername.txt"
            robocopy /e /r:0 /w:0 /zb $cpsrc $cpdes
        } else {
            robocopy /e /r:0 /w:0 $cpsrc $cpdes
        }
    }

    if ($copyfromcomputer -eq "yes" ) {
        New-Item -ItemType directory -Path "$outostdest"
        robocopy /e /r:0 /w:0 /zb $outostpath $outostdest *.pst
    }
    Return
}
function setACLPermissions () {
    # Check for existence of folder. If folder is not located on server
    # Automatically create the folder on the share and properly set permissions
    if (!(Test-Path -Path $baseUNCPath\Users\$usrsname)) {
        New-Item -ItemType Directory $baseUNCPath\Users\$usrsname
        $egACL="$baseUNCPath\$templateFolder"
        $acl=Get-Acl $egACL
        $ar1=New-Object System.Security.AccessControl.FileSystemAccessRule("higheredchilddomain\computer center administrators","fullcontrol","containerinherit,objectinherit","none","allow")
        $ar2=New-Object System.Security.AccessControl.FileSystemAccessRule("higheredchilddomain\$usrsname","fullcontrol","containerinherit,objectinherit","none","allow")
        $acl.AddAccessRule($ar1)
        $acl.AddAccessRule($ar2)
        Set-Acl $baseUNCPath\Users\$usrsname $acl
    }
    Return
}

if ($copyfromcomputer -eq "yes" ) {
    # Copy from old computer to server by an admin
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