# Photo dimensions should be 96x96 or 64x64
# Photo should be JPG
# Must use Windows PowerShell (not "PowerShell")
$targetUser="<username>"
$photoPath="<full path to photo>"
$photo = [byte[]](Get-Content $photoPath -Encoding byte)
Set-ADUser $targetUser -Replace @{thumbnailPhoto=$photo}
# Write-Host $photo