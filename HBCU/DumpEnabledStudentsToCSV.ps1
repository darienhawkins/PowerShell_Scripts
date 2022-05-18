# Important information obfuscated (hostname, IP address, username, password, etc)

$curDatetime=(date -Format yyyyMMddmmss).ToString()
#$csvPath="\\fileserver01\ows$\StudentDump\studentcsvoutput_$curDatetime.csv"
$csvPath="\\fileserver01\ows$\StudentDump\studentcsvoutput.csv"
Get-ADUser `
    -Filter {(name -like "*") -and (uid -like "00*") -and (enabled -eq $true)} `
    -SearchBase "OU=Students,DC=higheredchilddomain,DC=higheredu,DC=edu" `
    -Properties mail,uid,initials | `
    Select-Object givenname,initials,surname,samaccountname,mail,@{name="uid";expression={$_.uid -join ";"}} | `
    Export-Csv $csvPath -NoTypeInformation