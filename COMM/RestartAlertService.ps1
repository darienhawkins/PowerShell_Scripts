$serviceName="CompanyX (DivX) digging Data Alert Service"
$serviceStatus="Running"
$isRunning=(Get-Service $serviceName).status
$serviceDisplayName=(Get-Service $serviceName).DisplayName
$todaysDate=(Get-Date).DateTime
$logText="$serviceDisplayName restarted at $todaysDate"
$logPath="C:\ProgramData\CompanyX\CompanyX (DivX) digging Data Alert Service\RestartLog.txt"
if ($isRunning -eq $serviceStatus) {
    # do nothing
} else {
    Start-Service $serviceName
    Out-File -FilePath $logPath -InputObject $logText -Append -Encoding utf8
}
