<#
    Auth: Hawkins, Darien H
          Director, Computer Center
    
    |--------------|---------|----------------------------------------------------
    |     Date     | Version | Action
    |--------------|---------|----------------------------------------------------
    | 11 Aug 2020  |  0.0.1  | Initital
    |--------------|---------|----------------------------------------------------
    
    Installs additional Adobe fonts from the Creative Cloud suite.
    
#>

$sourceShare="\\genericfileserver01\Shares"
$fontSourceFolder=$sourceShare+"\Applications\Adobe\AdobeFonts"
$fontNamespace = 0x14
$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace($fontNamespace)
$fontFolder = "C:\Windows\Fonts"

# Install Adobe fonts from a source folder
foreach ($file in Get-ChildItem $fontSourceFolder) {
    if (Test-Path "$fontFolder\$file") {
        # If font already installed, skip and do nothing
        Read-Host "is it there?"
    }
    else {
        $objFolder.CopyHere($file.fullname)
        #Copy-Item $fontSourceFolder\$file $fontFolder -PassThru
    }
}

#if (Test-Path "$fontFolder\$($file.name)") {