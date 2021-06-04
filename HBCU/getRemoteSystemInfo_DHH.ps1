# Important information obfuscated (hostname, IP address, username, password, etc)

# Take entered computer name as an argument
Param(
   [Parameter(Position=1)]
   [string]$target
)

# Clear screen
clear-host

function checkComputerReachable {

    # Check to see if the computer is active by testing connection to port 135
    if ((Test-NetConnection $target -Port 135).TcpTestSucceeded -eq $true) {
        # If connection successful, continue
        getRemoteSystemInfo
    } else {
        # If computer is not active, inform user and exit
        write-host "Computer"$target"does not seem be reachable."
    }
}

function getRemoteSystemInfo {
    
    # Meat of the script
    $compName=(Get-CimInstance win32_computersystem -ComputerName $target).Name
    $ipAddr=(Get-ADComputer -Identity $target -Properties ipv4address).ipv4address
    $compDisName=(Get-ADComputer -Identity $target -Properties ipv4address).DistinguishedName
    $loggedOnUser=(Get-CimInstance win32_computersystem -ComputerName $target).UserName
    $compManufacture=(Get-CimInstance win32_computersystem -ComputerName $target).Manufacturer
    $compModel=(Get-CimInstance win32_computersystem -ComputerName $target).Model
    $serialNumber=(Get-CimInstance win32_bios -ComputerName $target).SerialNumber
    $biosVersion=(Get-CimInstance win32_bios -ComputerName $target).SMBIOSBIOSVersion
    $os=(Get-CimInstance win32_operatingsystem -ComputerName $target).Caption
    $osVersion=(Get-CimInstance win32_operatingsystem -ComputerName $target).Version
    $osArch=(Get-CimInstance win32_operatingsystem -ComputerName $target).OSArchitecture
    $osInstallDate=(Get-CimInstance win32_operatingsystem -ComputerName $target).InstallDate
    $instapp=(Get-CimInstance Win32_installedwin32program -ComputerName $target)|Format-List name,Version
    Write-Host "==========================================================="

    Write-Host "Computer name:"$compName
    Write-Host "Computer IP Address:"$ipAddr
    Write-Host "Computer Distinguished Name:"$compDisName
    Write-Host "Current Logged on User:"$loggedOnUser
    Write-Host "Computer Manufacture:"$compManufacture
    Write-Host "Computer Model:"$compModel
    Write-Host "Computer Serial Number:"$serialNumber
    Write-Host "Computer BIOS Version:"$biosVersion
    Write-Host "Operating System:"$os
    Write-Host "OS Version:"$osVersion
    Write-Host "OS Architecturer:"$osArch
    Write-Host "OS Install Date:"$osInstallDate
    Write-Host "Installed Applications:"
    $instapp
}

function main {
    # If computer name is not provided as an argument, prompt to enter here
    if (!$target) {
        $target=Read-Host "Enter Computer name"
    }
    checkComputerReachable
}

#Start the script at the "main" function
main