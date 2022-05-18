# Important information obfuscated (hostname, IP address, username, password, etc)

<#

Author:     Darien Hawkins <directorccorgmailbox@higheredinstitutiondomain.edu>
Version:    1.0
Date:       13 May 2020
Purpose:    Import students from csv file generated from ERPApplication/TOAD
            Replace old batch file using soon-to-be deprecated commands
            No longer require seperate text file for third-party ID and PW

#>

Clear-Host

# Declare script global variables
$preferredDC="domaincontroller02"
$csvPath="C:\Temp"
$logPath="$csvPath\Scripts\Logs"
$oldPath="$csvPath\Scripts\Old"
$studentImportFullPath=""
$studentImportFile=""
$studentImportFileName=""
$Desc="OFF CAMPUS"
$studentGroups="All Users","EDUStudents","Wireless 1","SomeGroupRegistration"
$timeStamp=get-date -Format yyyyMMdd@hhMMss

# Main function to test for the existance of the CSV file and passes focus to functions
function main {
    $isFilePresent=Test-Path $csvPath\*.csv
    if ($isFilePresent) {
        $studentImportFullPath=(Get-Item $csvPath\*.csv).FullName
        $studentImportFile=Import-Csv -path $studentImportFullPath
        createStudentAccounts
        copyCSVToOldFolder
    } else {
        Write-Host "No CSV file present at $csvPath. Exiting script."
        Exit
    }
}

# Creates the student accounts and writes logs
function createStudentAccounts {
    foreach ($curStu in $studentImportFile) {
        # Derives and sets organizational unit from student's DN
        $orgUnit=$curStu.dn.Substring($curStu.dn.Length - 41)
        # Derives and sets default password
        $passwd=$curStu.GIVENNAME.Substring(0,1)+$curStu.SN.Substring(0,1)+$curStu.UID.Substring($curStu.UID.Length - 4)
        $passwdSecure=ConvertTo-SecureString $passwd.ToLower() -AsPlainText -Force
    
        #Creates the user, enables the account, and sets custom attributes
        New-ADUser `
            -Name $curStu.NAME `
            -UserPrincipalName $curStu.USERPRINCIPALNAME `
            -SamAccountName $curStu.SAMACCOUNTNAME `
            -Path $orgUnit `
            -GivenName $curStu.GIVENNAME `
            -Surname $curStu.SN `
            -Initials $curStu.INITIALS `
            -DisplayName $curStu.DISPLAYNAME `
            -AccountPassword $passwdSecure `
            -EmailAddress $curStu.MAIL `
            -Description $Desc `
            -Title $curStu.TITLE `
            -Enabled $true `
            -Server $preferredDC `
            -OtherAttributes @{uid = $curStu.UID ; customgmail = $curStu.CUSTOMGMAIL ; info = $curStu.INFO} `
            -Office $passwd.ToLower() <# Only to see if pwd is generated correctly #> `
            -ErrorVariable err1 `
            -OutVariable out1 `
            -ErrorAction SilentlyContinue `
            -PassThru
        
        if (!$err1) {
            # Pass to function to add student to necessary groups
            addStudentToGroups ($curStu.SAMACCOUNTNAME)
            # Write to success file if no error value passed to err1
            Out-File -InputObject $out1 -FilePath $logPath\accountcreatesuccess$timeStamp.txt -Append
        } else {
            # Write output and error logs if error value passed to err1
            $curProcessed=$curStu.SAMACCOUNTNAME+", "
            Out-File -InputObject $curProcessed -FilePath $logPath\accountcreateerror$timeStamp.txt -Append -NoNewline
            Out-File -InputObject $err1 -FilePath $logPath\accountcreateerror$timeStamp.txt -Append
        }
    }
}

# Takes passed argument as a parameter and adds the created student to the necessary groups
function addStudentToGroups {
    param ($curSstuToAdd)
    foreach ($curStuGroup in $studentGroups) {
        Add-ADGroupMember `
            -Identity $curStuGroup `
            -Members $curSstuToAdd `
            -Server $preferredDC
    }
}

# Copies the CSV file to an "old" folder and delete after confirmation
function copyCSVToOldFolder {
    $studentImportFileName=(Get-Item $csvPath\*.csv).Name
    Copy-Item $studentImportFullPath $oldPath -Force -ErrorAction SilentlyContinue
    if (Test-Path $oldPath\$studentImportFileName) {
        #Remove-Item $studentImportFullPath
    }
}

# Script run starts here.
main