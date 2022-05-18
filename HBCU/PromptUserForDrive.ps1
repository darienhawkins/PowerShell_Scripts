# Important information obfuscated (hostname, IP address, username, password, etc)

Clear-Host
$drivesOnSystem=(Get-PSDrive -PSProvider FileSystem)
$drivesOnSystem
$count=0
function lookForDrives {
    $count++
    if ($count -eq 11) {
        Write-Host "You have tried 11 times.  Exiting!"
        exit
    }
    $userSelected=read-Host "Type a drive letter"
    foreach ($currDrive in $drivesOnSystem) {
        if ($userSelected -eq ($currDrive.name).ToString()) {
            $stringUserPath=$currDrive.Root.ToString()+"users"
            if (test-path $stringUserPath) {
                Clear-Host
                Write-Host "Drive"$userSelected":\ selected and the Users folder is found. `n "
                (Get-ChildItem $stringUserPath).FullName
                read-Host "Type user's name to backup"
                exit
            } else {
                Write-Host "Drive"$userSelected":\ selected, but the Users folder is ** NOT ** found.  Try again."
                lookForDrives
            }
        }
    }
    Write-Host "Selected drive"$userSelected":\ not found on this system.  Try again"
    lookForDrives
}

lookForDrives