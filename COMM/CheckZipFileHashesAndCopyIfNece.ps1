function CheckZipFileHashesAndCopyIfNecessary()
{
    [string]$remoteSourcePath="\\server\serversare\Engineering\RD-Software\Test"
    [string]$localDestinationPath="C:\temp\Hold"
    [string]$targetFileName="Diag-Exple.API.zip"
    [string]$sys32Dir="$env:windir\system32"
    
    # Get hashes
    [string]$remoteSourceFileHash=(Get-FileHash -Algorithm SHA256 $remoteSourcePath\$targetFileName).Hash
    [string]$localFileHash=(Get-FileHash -Algorithm SHA256 $localDestinationPath\$targetFileName -ErrorAction SilentlyContinue).Hash
    
    # If hashes differ, copy file; otherwise, leave destination intact and continue
    if ($remoteSourceFileHash -ne $localFileHash) 
    {
        Write-Host "File is either not present or differs from the source. Copying source file to destination."
        Start-Process -NoNewWindow -Wait -FilePath $sys32Dir\Robocopy.exe -ArgumentList "/R:0 /W:1 $remoteSourcePath $localDestinationPath $targetFileName"
    } else
    {
        Write-Host "Files are there and the same." -ErrorAction SilentlyContinue
        return
    }    
}