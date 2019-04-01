<#

.SYNOPSIS
This is a Powershell script to help install Windows RSAT Tools for Windows 1809 and later

.DESCRIPTION
This is a Powershell script to help install Windows RSAT Tools for Windows 1809 and later

.EXAMPLE
Gui Mode
./install_Rsat_1809.exe
Silent Mode install all features
./install_Rsat_1809.exe -silent -all
Silent Mode remove all features
./install_Rsat_1809.exe -silent -all [-action 'remove'] 
Silent Mode install specific features
./install-Rsat_1809.exe -silent [-ADDS -GPO -Bitlocker -WSUS -DHCP -DNS]

.NOTES
Run in gui mode by default.
Throw silent switch to run it with no interaction

.LINK
http://kevinpelgrims.wordpress.com

#>

[CmdletBinding()]
Param (
    $action="install",
    [switch]$silent=$false,
    [switch]$all=$true,
    [switch]$ADDS=$false
)


Function GUI {
    
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'RSAT Tools to install'
    $form.Size = New-Object System.Drawing.Size(300,450)
    $form.StartPosition = 'CenterScreen'

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(75,370)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = 'OK'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Point(150,370)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = 'Cancel'
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $CancelButton
    $form.Controls.Add($CancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = 'Please choose RSAT Tools from the list below:'
    $form.Controls.Add($label)

    $listBox = New-Object System.Windows.Forms.Listbox
    $listBox.Location = New-Object System.Drawing.Point(10,40)
    $listBox.Size = New-Object System.Drawing.Size(260,320)
    $listBox.AutoSize = $true
    $listBox.SelectionMode = 'MultiExtended'

    [void] $listBox.Items.Add('Active Directory DS-LDS')
    [void] $listBox.Items.Add('Bitlocker Recovery')
    [void] $listBox.Items.Add('Certificate Services')
    [void] $listBox.Items.Add('DHCP')
    [void] $listBox.Items.Add('DNS')
    [void] $listBox.Items.Add("Failover Cluster Management")
    [void] $listBox.Items.Add('File Services')
    [void] $listBox.Items.Add('Group Policy Management')
    [void] $listBox.Items.Add('IPAM Client')
    [void] $listBox.Items.Add('LLDP')
    [void] $listBox.Items.Add('Network Controller')
    [void] $listBox.Items.Add("Network Load Balancing")
    [void] $listBox.Items.Add('Remote Access Management')
    [void] $listBox.Items.Add('Remote Desktop Services')
    [void] $listBox.Items.Add('Server Manager')
    [void] $listBox.Items.Add('Shielded VM')
    [void] $listBox.Items.Add('Storage Replica')
    [void] $listBox.Items.Add('Storage Migration Service Management')
    [void] $listBox.Items.Add('System Insights Management')
    [void] $listBox.Items.Add('Volume Activation')
    [void] $listBox.Items.Add('WSUS')

    $listBox.Height = 70
    $form.Controls.Add($listBox)
    $form.Topmost = $true

    $selectAllCheckbox = New-Object System.Windows.Forms.CheckBox
    $selectAllCheckbox.Location = New-Object System.Drawing.Point(10,320)
    $selectAllCheckbox.Text = "Select all Items"
    $selectAllCheckbox.Add_Click({
           if ($selectAllCheckbox.Checked -eq $true ) {
                 for ($i = 0; $i -lt $listBox.Items.Count; $i++) {
                    $listBox.SetSelected($i, $true)
                  }
            }
            elseif ( $selectAllCheckBox.Checked -eq $false) {
                 $listBox.ClearSelected()
            }})
    $form.Controls.Add($selectAllCheckbox)

    $uninstallAction = New-Object System.Windows.Forms.CheckBox
    $uninstallAction.Location = New-Object System.Drawing.Point(10,341)
    $uninstallAction.Size = New-Object System.Drawing.Size(200,20)
    $uninstallAction.Text = "Uninstall Selected Tools"

    $form.Controls.Add($uninstallAction)



    $result = $form.ShowDialog()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $selectionsize = $listBox.SelectedItems.count 
        $selections = $listBox.SelectedItems
        if ( $uninstallAction.Checked -eq $true ) {
            Uninstall($listBox.SelectedItems)
            }
        else {
            Install($listBox.SelectedItems)
            }
    }


}


Function RegistryEdit {
    #Turn on online resources for RSAT Tools
    $RegistryPath = "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Servicing"
    $RegistryName1 = "LocalSourcePath"
    $RegistryName2 = "RepairContentServerSource"
    $RegistryValue2 = "2"
    $RegistryValue1 = "" 

    if (!(Test-Path -Path $RegistryPath)) {
        New-Item -Path $RegistryPath
        New-ItemProperty -Path $RegistryPath -PropertyType ExpandString -Name $RegistryName1 -Value $RegistryValue1 -Force | Out-Null
        New-ItemProperty -Path $RegistryPath -PropertyType DWord -Name $RegistryName2 -Value $RegistryValue2 -Force | Out-Null
     }
     else {
        New-ItemProperty -Path $RegistryPath -PropertyType DWord -Name $RegistryName2 -Value $RegistryValue2 -Force | Out-Null
        New-ItemProperty -Path $RegistryPath -PropertyType ExpandString -Name $RegistryName1 -Value $RegistryValue1 -Force | Out-Null
     }
}

Function Install($selections)

{
    If ( ($selections.Count -eq 21) -or ($silent -and $all )) {
        Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.CertificateServices.Tools~~~~0.0.1.0
        Add-WindowsCapability -Online -Name Rsat.DHCP.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.Dns.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.FileServices.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.IPAM.Client.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.LLDP.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.NetworkController.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.NetworkLoadBalancing.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.ServerManager.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.Shielded.VM.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.StorageReplica.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.VolumeActivation.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.WSUS.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.StorageMigrationService.Management.Tools~~~~0.0.1.0 
        Add-WindowsCapability -Online -Name Rsat.SystemInsights.Management.Tools~~~~0.0.1.0
    }
    else {
        For ($i=0; $i -lt $selections.Count; $i++) {
            if (( $selections[$i] -eq 'Active Directory DS-LDS' ) -or ($silent -and $ADDS )) {
                Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
                }
            elseif (( $selections[$i] -eq 'Bitlocker Recovery') -or ($silent -and $Bitlocker )) {
                Add-WindowsCapability -Online -Name Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0
                }
            elseif (( $selections[$i] -eq 'Certificate Services') -or ($silent -and $CertificateServices )) {
                Add-WindowsCapability -Online -Name Rsat.CertificateServices.Tools~~~~0.0.1.0 
                }
            elseif (( $selections[$i] -eq 'DHCP' ) -or ($silent -and $DHCP )) {
                Add-WindowsCapability -Online -Name Rsat.DHCP.Tools~~~~0.0.1.0
                }
            elseif (( $selections[$i] -eq 'DNS' ) -or ($silent -and $DNS )) {
                Add-WindowsCapability -Online -Name Rsat.Dns.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'Failover Cluster Management' ) {
                Add-WindowsCapability -Online -Name Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'File Services' ) {
                Add-WindowsCapability -Online -Name Rsat.FileServices.Tools~~~~0.0.1.0
                }
            elseif (( $selections[$i] -eq 'Group Policy Management' ) -or ($silent -and $GPO )){
                Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'IPAM Client' ) {
                Add-WindowsCapability -Online -Name Rsat.IPAM.Client.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'LLDP' ) {
                Add-WindowsCapability -Online -Name Rsat.LLDP.Tools~~~~0.0.1.0 
                }
            elseif ( $selections[$i] -eq 'Network Controller' ) {
                Add-WindowsCapability -Online -Name Rsat.NetworkController.Tools~~~~0.0.1.0 
                }
            elseif ( $selections[$i] -eq 'Network Load Balancing' ) {
                Add-WindowsCapability -Online -Name Rsat.NetworkLoadBalancing.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'Remote Access Management' ) {
                Add-WindowsCapability -Online -Name Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'Remote Desktop Services' ) {
                Add-WindowsCapability -Online -Name Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0 
                }
            elseif ( $selections[$i] -eq 'Server Manager' ) {
                Add-WindowsCapability -Online -Name Rsat.ServerManager.Tools~~~~0.0.1.0 
                }
            elseif ( $selections[$i] -eq 'Shielded VM' ) {
                Add-WindowsCapability -Online -Name Rsat.Shielded.VM.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'Storage Replica' ) {
                Add-WindowsCapability -Online -Name Rsat.StorageReplica.Tools~~~~0.0.1.0 
                }
            elseif ( $selections[$i] -eq 'Storage Migration Service Management' ) {
                Add-WindowsCapability -Online -Name Rsat.StorageMigrationService.Management.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'System Insights Management' ) {
                Add-WindowsCapability -Online -Name Rsat.SystemInsights.Management.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'Volume Activation' ) {
                Add-WindowsCapability -Online -Name Rsat.VolumeActivation.Tools~~~~0.0.1.0 
                }
            elseif (( $selections[$i] -eq 'WSUS' ) -or ($silent -and $WSUS )) {
                Add-WindowsCapability -Online -Name Rsat.WSUS.Tools~~~~0.0.1.0 
                }
        }
             
    }
}  
Function Uninstall($selections)
{
    If (( $selections.Count -eq 21 ) -or ($silent -and $all )) {
        Remove-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.CertificateServices.Tools~~~~0.0.1.0
        Remove-WindowsCapability -Online -Name Rsat.DHCP.Tools~~~~0.0.1.0
        Remove-WindowsCapability -Online -Name Rsat.Dns.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0
        Remove-WindowsCapability -Online -Name Rsat.FileServices.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.IPAM.Client.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.LLDP.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.NetworkController.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.NetworkLoadBalancing.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.ServerManager.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.Shielded.VM.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.StorageReplica.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.VolumeActivation.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.WSUS.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.StorageMigrationService.Management.Tools~~~~0.0.1.0 
        Remove-WindowsCapability -Online -Name Rsat.SystemInsights.Management.Tools~~~~0.0.1.0
    }
    else {
        For ($i=0; $i -lt $selections.Count; $i++) {
            if (( $selections[$i] -eq 'Active Directory DS-LDS' ) -or ($silent -and $ADDS )) {
                Remove-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
                }
            elseif (( $selections[$i] -eq 'Bitlocker Recovery') -or ($silent -and $Bitlocker )) {
                Remove-WindowsCapability -Online -Name Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0
                }
            elseif (( $selections[$i] -eq 'Certificate Services') -or ($silent -and $CertificatesServices )) {
                Remove-WindowsCapability -Online -Name Rsat.CertificateServices.Tools~~~~0.0.1.0 
                }
            elseif (( $selections[$i] -eq 'DHCP' ) -or ($silent -and $DHCP )) {
                Remove-WindowsCapability -Online -Name Rsat.DHCP.Tools~~~~0.0.1.0
                }
            elseif (( $selections[$i] -eq 'DNS' ) -or ($silent -and $DNS )) {
                Remove-WindowsCapability -Online -Name Rsat.Dns.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'Failover Cluster Management' ) {
                Remove-WindowsCapability -Online -Name Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'File Services' ) {
                Add-WindowsCapability -Online -Name Rsat.FileServices.Tools~~~~0.0.1.0
                }
            elseif (( $selections[$i] -eq 'Group Policy Management' ) -or ($silent -and $GPO )) {
                Remove-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'IPAM Client' ) {
                Remove-WindowsCapability -Online -Name Rsat.IPAM.Client.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'LLDP' ) {
                Remove-WindowsCapability -Online -Name Rsat.LLDP.Tools~~~~0.0.1.0 
                }
            elseif ( $selections[$i] -eq 'Network Controller' ) {
                Remove-WindowsCapability -Online -Name Rsat.NetworkController.Tools~~~~0.0.1.0 
                }
            elseif ( $selections[$i] -eq 'Network Load Balancing' ) {
                Remove-WindowsCapability -Online -Name Rsat.NetworkLoadBalancing.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'Remote Access Management' ) {
                Remove-WindowsCapability -Online -Name Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'Remote Desktop Services' ) {
                Remove-WindowsCapability -Online -Name Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0 
                }
            elseif ( $selections[$i] -eq 'Server Manager' ) {
                Remove-WindowsCapability -Online -Name Rsat.ServerManager.Tools~~~~0.0.1.0 
                }
            elseif ( $selections[$i] -eq 'Shielded VM' ) {
                Remove-WindowsCapability -Online -Name Rsat.Shielded.VM.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'Storage Replica' ) {
                Remove-WindowsCapability -Online -Name Rsat.StorageReplica.Tools~~~~0.0.1.0 
                }
            elseif ( $selections[$i] -eq 'Storage Migration Service Management' ) {
                Remove-WindowsCapability -Online -Name Rsat.StorageMigrationService.Management.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'System Insights Management' ) {
                Remove-WindowsCapability -Online -Name Rsat.SystemInsights.Management.Tools~~~~0.0.1.0
                }
            elseif ( $selections[$i] -eq 'Volume Activation' ) {
                Remove-WindowsCapability -Online -Name Rsat.VolumeActivation.Tools~~~~0.0.1.0 -InformationAction Inquire
                }
            elseif (( $selections[$i] -eq 'WSUS' ) -or ($silent -and $WSUS )) {
                Remove-WindowsCapability -Online -Name Rsat.WSUS.Tools~~~~0.0.1.0 
                }
        }
             
    }
}  


if ($silent) {
   RegistryEdit
       if($action -eq "remove") {
           Uninstall
       }
       elseif ($action -eq "install") {
           Install
       }
       elseif ( $action -eq "" ) {
            Write-Host 'get-help install_Rsat_1809.ps1 -examples'
       }
}
else {
    RegistryEdit
    GUI
}
