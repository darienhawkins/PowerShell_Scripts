<##############################################################################

Date Created:       02 Jun 2021
Date Modified:      02 Jun 2021
Version:            1.0.0
Author:             Darien Hawkins (darien-hawkins@hotmail.com)
Descripton:         To calculate a hash from a passed string parameter
                    or a pipeline input.  This code is based on Microsoft
                    suggested example.
Microsoft URL:      https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash?view=powershell-7.1

###############  Update History  ##############################################
    Date    |  ver  |  Notes
------------|-------|----------------------------------------------------------
02 Jun 2021 | 1.0.0 | Initial draft
------------|-----  |----------------------------------------------------------
##############################################################################>

function Get-StringHash
{
    [CmdletBinding()]
    param
    (
        # Text string to be hashed. Must be enclosed in quotes.
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]$TextString,
        # Select from valid algorithms, will autocomplete.
        [Parameter(Mandatory=$false)]
        [ValidateSet("MD5","SHA1","SHA256","SHA384","SHA512")]
        [string]$Algorithm
    )
    # If algorithm not set, then default to SHA256
    if (!$Algorithm) {$Algorithm="SHA256"}
    $stringAsStream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.StreamWriter]::new($stringAsStream)
    # Here is where the passed string is used
    $writer.write($TextString)
    $writer.Flush()
    $stringAsStream.Position = 0
    (Get-FileHash -InputStream $stringAsStream -Algorithm $Algorithm).Hash
}