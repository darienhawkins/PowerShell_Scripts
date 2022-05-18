<##############################################################################

  Date Created:     31 Aug 2021
  Date Modified:    31 Aug 2021
  Version:          1.0
  File Name:        MoveOldFiles_compxserverfs05_-----_v1.0.ps1
  Authored By:      Darien Hawkins (IT xxxx)
                    darien.hawkins@CompanyX.com
                    -----
  Company:          CompanyX
  Department:       BBBXNA IT Dpt
  Purpose:          To programmatically remove/archive older .zip files based
                    on the "year" matching in the file name and the date modified

###############  Update History  ##############################################
   Date     | Seq |  Action
------------|-----|------------------------------------------------------------
31 Aug 2021 | 001 | Initial draft
------------|-----|------------------------------------------------------------
###############################################################################

# Enumerate the years and copy/move files that match the year
# in both the file name and the date modified (LastWriteTime)
# to free space on the G: drive on compxserverfs05
###############################################################################>


$pastYears="2015","2014","2013","2012","2011","2010"
foreach ($year in $pastYears)
{
    $srcFolder="G:\research-dev-Software\vehicle-Data\vehicleDataFiles\"
    $desFolder="E:\vehicle-data-Zips\vehicleData-$year"
    Set-Location $srcFolder
    $enumOfDirs=(Get-ChildItem).FullName
    foreach ($curntDir in $enumOfDirs) 
    {
        Set-Location $curntDir
        $enumOfFiles=((Get-ChildItem "*$year*")|Where-Object {$_.LastWriteTime -like "*$year*"}).FullName
        foreach ($curItem in $enumOfFiles) 
        {
            Move-Item $curItem $desFolder
            # Copy-Item $curItem $desFolder
            # echo $curItem
            # echo $desFolder
        }
    }
}