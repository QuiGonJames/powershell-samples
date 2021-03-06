# Detect SMBv1
sc.exe qc lanmanworkstation
$isIt = Get-WindowsOptionalFeature -Online -FeatureName smb1protocol
$isIt

if ($isIt -eq $null -or ($isIt).State -ne 'Enabled')
{
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Enable SMBv1. WARNING! This is an insecure protocol!'
    $no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Leave SMBv1 disabled. This protects against intrusions.'
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = (Get-Host).UI.PromptForChoice('Enable SMB?', 'SMB is NOT enabled. Would you like to enable it?', $options, 1)

    if ($result -eq 0)
    {
        # Enable SMBv1
        Add-WindowsCapability -Online -Name SMB1Protocol-Client 
        # Enable the group feature
        Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
        # Disable the sub-features not wanted
        Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Server -NoRestart
        Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Deprecation
        sc.exe config lanmanworkstation depend=bowser/mrxsmb10/mrxsmb20/nsi
        sc.exe config mrxsmb10 start=auto
    }
}
else
{
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Disables SMBv1. This protects against intrusions.'
    $no = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Leave SMBv1 enabled. WARNING! This is an insecure protocol!'
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $result = (Get-Host).UI.PromptForChoice('Disable SMB?', 'SMB is enabled. Would you like to disable it?', $options, 0)

    if ($result -eq 0)
    {
        #disable SMBv1
        sc.exe config lanmanworkstation depend=bowser/mrxsmb20/nsi
        sc.exe config mrxsmb10 start=disabled
        Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
        #Doesn't work
        # Restart-Service -Name LanmanWorkstation -Force -ErrorAction Continue
    }
}