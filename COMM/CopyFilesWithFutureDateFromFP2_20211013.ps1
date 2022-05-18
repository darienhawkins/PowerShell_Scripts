$baseLocalDir="F:\research-dev-Software\vehicle-Data\"
$remoteServerUNC="\\windowsserver.dz.CompanyX.com\"
$remoteVehicleDir="SomeFiles_For_P1"
$futureFilesDir=$baseLocalDir+"vehicleDataFuture"

# For years 2022 through 2100
for ($iy=2022; $iy -le 2100; $iy=$iy+1 )
{
    foreach ($curVehicleDir in $remoteVehicleDir) {
        $vehicleDir=$remoteServerUNC+$curVehicleDir
        foreach ($curFldr in (Get-ChildItem $vehicleDir).FullName) 
        {
            $filesInTheFuture=(Get-ChildItem $curFldr -Recurse | Where-Object {$_.name -like "vehicle*_"+$iy+"_*"}).FullName
            Move-Item $filesInTheFuture $futureFilesDir
        }
    }
}