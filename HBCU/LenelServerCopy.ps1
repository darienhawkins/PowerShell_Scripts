# Important information obfuscated (hostname, IP address, username, password, etc)

# *****************************************************************************
#	Copy LenelServer files
#	Service to copy oncampus student records [with housing status, registered [active/inactive] 
#	and faculty and staff [active/inactive] records to Lenel Server
#	Updated: 14 April 2021, Darien Hawkins (update source server path)
#	Updated: 24 March 2021, Darien Hawkins (update source server path)
#	Updated: 15 October 2018, Mauyan Skeete
#	Version 1.1
#   
# *****************************************************************************

# Set source and destination directory paths
#$srcPath="\\HIGHEREDPWXAGNT01\LenelServer$"
#$bckupPath="$srcPath\bckupPath"
$srcPath="\\fileserver01\reports$\Argos_Evisions\Lenel"
$bckupPath="$srcPath\Lenel-Archive-AfterMovedandProcessed"
$desPath="\\192.123.84.254\fromERPApplication$"

# Get and format date as: year, month, day, hour, minute, second
$appendDate=Get-Date -UFormat %Y%m%d%H%M%S

# Get all files in source path
$getFiles=Get-ChildItem -File $srcPath\*.txt

# Process all files, rename, and append formatted date
foreach ($processFile in $getFiles) {
    $processFileName=$processFile.Name
    Copy-Item $srcPath\$processFileName $bckupPath\$processFileName-$appendDate
	Copy-Item $srcPath\$processFileName $desPath\$processFileName
    }
