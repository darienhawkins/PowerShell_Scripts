$baseDir="g:\research-dev-Software\vehicle-Data\"
$vehicleDir=$baseDir+"vehicleDataFiles"
$futureFilesDir=$baseDir+"vehicleDataFuture"

# For years 2022 through 2100
for ($iy=2022; $iy -le 2100; $iy=$iy+1 )
{
    foreach ($curFldr in (Get-ChildItem $vehicleDir).FullName) 
    {
        $filesInTheFuture=(Get-ChildItem $curFldr -Recurse | Where-Object {$_.name -like "vehicle*_"+$iy+"_*"}).FullName
        Write-Host $filesInTheFuture
        Move-Item $filesInTheFuture $futureFilesDir
    }
}

# For year 2021, month 9 only
for ($ia=9; $ia -lt 10; $ia=$ia+1 )
{
    foreach ($curFldr in (Get-ChildItem $vehicleDir).FullName) 
    {
        $filesInTheFuture=(Get-ChildItem $curFldr -Recurse | Where-Object {$_.name -like "vehicle*_2021_0"+$ia+"_*"}).FullName
        Write-Host $filesInTheFuture
        Move-Item $filesInTheFuture $futureFilesDir
    }
}

# For year 2021, months 10 through 12
for ($im=10; $im -le 12; $im=$im+1 )
{
    foreach ($curFldr in (Get-ChildItem $vehicleDir).FullName) 
    {
        $filesInTheFuture=(Get-ChildItem $curFldr -Recurse | Where-Object {$_.name -like "vehicle*_2021_"+$im+"_*"}).FullName
        Write-Host $filesInTheFuture
        Move-Item $filesInTheFuture $futureFilesDir
    }
}

# For year 2021, month 8, days 18 through 31
for ($id=18; $id -le 31; $id=$id+1 )
{
    foreach ($curFldr in (Get-ChildItem $vehicleDir).FullName) 
    {
        $filesInTheFuture=(Get-ChildItem $curFldr -Recurse | Where-Object {$_.name -like "vehicle*_2021_08_"+$id+"_*"}).FullName
        Write-Host $filesInTheFuture
        Move-Item $filesInTheFuture $futureFilesDir
    }
}