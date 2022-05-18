# Important information obfuscated (hostname, IP address, username, password, etc)

Import-Module activedirectory

function creatNewPeep {

$company="HigherED University"
$domain="higheredchilddomain.higheredinstitutionnameU.edu"
$strAddr="123 Edu WAY"

$ploc="The Password goes here"
$pass=ConvertTo-SecureString -String $ploc -AsPlainText -Force
$ouPath="OU=Contracted staff,OU=VENDORS,DC=higheredchilddomain,DC=highered,DC=edu"
$descrp="Description or Job Title"
$departmnt="User's Department"
$PeepsToCreate=Import-Csv "path to file (csv or txt)"

foreach ($currPerson in $PeepsToCreate) {

    $firstname=$currPerson.first.ToUpper()
    $lastname=$currPerson.last.ToUpper()
    $usrname=$firstname.$lastname

    echo $firstname"."$lastname"@$domain"

    #<#
    New-ADUser -Name $firstname" "$lastname `
               -SamAccountName $firstname"."$lastname `
               -GivenName $firstname `
               -Surname $lastname `
               -Path $ouPath `
               -UserPrincipalName $firstname"."$lastname"@$domain" `
               -Enabled $true `
               -AccountPassword $pass -ChangePasswordAtLogon $True `
               -DisplayName $lastname" "$firstname `
               -City "AnyCityUSA" `
               -Company $company `
               -State "Somestate" `
               -PostalCode "55555" `
               -StreetAddress $strAddr `
               -Title $descrp `
               -Department $departmnt `
               -Office $departmnt `
               -Description $descrp
               #-WhatIf
    #>
    
    }
}
