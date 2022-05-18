function DeleteFileFromwinservprodx1{
    $userDomain="DOMNETBIOSNAME"
    # https://compxhushserver/compxhushServer/app/#/compxhush/212/general
    $username = "$userDomain\CompXserverwinservprodx1"
    $clearTextPW='xxxxxxx'
    ############################################################
    $password = ConvertTo-SecureString $clearTextPW -AsPlainText -Force
    $targetComputer = "compxserverPRO01.dz.CompanyX.com"

    $cred = new-object -typename System.Management.Automation.PSCredential `
        -argumentlist $username, $password

    Invoke-Command -computername $targetComputer `
        -scriptblock { 
            # $path = '\\compxserverSTG1.dz.CompanyX.com\UserUpload\Targets\vehicleDiagnostics.API.SetParameters.xml'
            $targetRemoteComputer = "compxserverPRO01.dz.CompanyX.com"
            $path = "\\$targetRemoteComputer\UserUpload\Targets\ggg.txt"
            Remove-Item -LiteralPath $path -force 
        } -Credential $cred
}