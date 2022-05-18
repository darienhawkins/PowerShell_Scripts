<##############################################################################

  Date Created:     25 Oct 2021
  Date Modified:    25 Oct 2021
  Version:          1.0
  File Name:        Export_vehicleCertficates_FP1-FP2_20211025.ps1
  Authored By:      Darien Hawkins (IT xxxx)
                    darien.hawkins@CompanyX.com
                    -----
  Company:          CompanyX
  Department:       BBBXNA IT Dpt
  Purpose:          To programmatically export vehicle certificates in PFX format
                    from user certificate store
  URLS:
  https://docs.microsoft.com/en-us/powershell/module/pki/export-pfxcertificate?view=windowsserver2019-ps

###############  Update History  ##############################################
   Date     | Seq |  Action
------------|-----|------------------------------------------------------------
25 Oct 2021 | 001 | Initial draft
------------|-----|------------------------------------------------------------
###############################################################################

This is to run from either FP1 or FP2.  Once pfx is exported, copy folder 
contents to OrgY network for compxhush Server injestion

###############################################################################>

$cerFlder="C:\Certs"
$thisDate=(Get-Date -Format yyyyMMdd)
$vehicles="53xxxxxx","53yyyyyy"
$mypwd = ConvertTo-SecureString -String "NoPasswdHere" -Force -AsPlainText
New-Item -ItemType Directory "$cerFlder\$thisDate"
foreach ($curvehicle in $vehicles) {
    $getCert=(Get-ChildItem -Path cert:\currentuser\my |Where-Object {$_.Subject -like "*$curvehicle*"})
    foreach ($curCert in $getCert){
        #echo $curCert
        #echo "$cerFlder\$thisDate\$curvehicle.pfx"
        Export-PfxCertificate -Cert $curCert -FilePath "$cerFlder\$thisDate\$curvehicle.pfx" -Password $mypwd
    }
}
