# Important information obfuscated (hostname, IP address, username, password, etc)

$peepsWithNOEmployeeID=Get-ADUser -Properties employeeid,uid,mail `
    -Filter { (uid -like "0*") -and ((Enabled -eq $true) -and (employeeid -notlike "*")) -and (mail -like "*@higheredinstitutionnameU.edu") -and (samaccountname -like "*.*") } `
    | Select-Object samaccountname,employeeid,mail,uid `
    | Where-Object mail -NotLike "*zoom*"

foreach ($curPeep in $peepsWithNOEmployeeID) {
        $empSam=$curPeep.samaccountname
        $empID=$curPeep.uid
        Write-Host $empSam $empID
        Get-ADUser -Server domaincontroller1 -Identity $empSam -Properties EmployeeID,mail,uid `
            | Select-Object employeeid,mail,samaccountname,@{name=”uid”;expression={$_.uid -join “;”}} `
            | export-csv -NoTypeInformation -Append C:\Temp\ppnoempid.txt
}

$readPeepsCSV=Import-Csv C:\Temp\ppnoempid.txt
foreach ($curPeep in $readPeepsCSV) {
    $empSam=$curPeep.samaccountname
    $empID=$curPeep.uid
    Write-Host $empSam $empID
    Set-ADUser -Server domaincontroller1 -Identity $empSam -Replace @{EmployeeID = $empID}
    Get-ADUser -Server domaincontroller1 -Identity $empSam -Properties EmployeeID,uid,mail
    #Pause
}


# @{name=”uid”;expression={$_.uid -join “;”}}