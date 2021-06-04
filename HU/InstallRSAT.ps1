$rsatTool2Install="Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0","Rsat.DHCP.Tools~~~~0.0.1.0","Rsat.Dns.Tools~~~~0.0.1.0", `
"Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0","Rsat.FileServices.Tools~~~~0.0.1.0","Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0", `
"Rsat.ServerManager.Tools~~~~0.0.1.0","Rsat.VolumeActivation.Tools~~~~0.0.1.0"

foreach ($currTool in $rsatTool2Install) {
    Write-Host "Installing RSAT Tool: $currTool"
    Add-WindowsCapability -Online -Name $currTool -ErrorAction SilentlyContinue
    }

Start-Process -WindowStyle Minimized powershell -ArgumentList "\\genericfileserver01\Shares\Applications\_BaselineAppInstaller\scripts\Upate-Help.ps1"