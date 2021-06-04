$eolSystems="win*7*"
$desFile="\\genericfileserver01\HUCIT\Documents\outputs\allenabledWin7computers.csv"
$desFile2="\\genericfileserver01\HUCIT\Documents\outputs\otherinfo.txt"
Get-ADComputer `
    -Filter {(operatingsystem -like $eolSystems) -and (Enabled -eq $true)} `
    -Properties operatingsystem,ipv4address | `
    Where-Object ipv4address -like "137*" | `
    Select-Object name,ipv4address,operatingsystem |`
    Export-Csv -NoTypeInformation $desFile

Read-Host "Hit any key to enter"

$win7Systems=Import-Csv $desFile
foreach ($curW7Sys in $win7Systems) {
    Write-Host $curW7Sys.name === $curW7Sys.ipv4address === $curW7Sys.operatingsystem|Tee-Object -Append $desFile2
    $curW7SysName=($curW7Sys.name).ToString()
    Get-WMIObject -class Win32_ComputerSystem -ComputerName $curW7Sys.name|select username,name,model|fl|Tee-Object -Append $desFile2
    Get-WMIObject -class Win32_ComputerSystemproduct -ComputerName $curW7Sys.name|select IdentifyingNumber|fl|Tee-Object -Append $desFile2
    Get-WmiObject -class win32_operatingsystem -ComputerName $curW7Sys.name|select version|fl|Tee-Object -Append $desFile2
    dir \\$curW7SysName\c$\users|Tee-Object -Append $desFile2
    Write-Host "=========================================="|Tee-Object -Append $desFile2
}