# smbv1-toggle

## This information is provided as-is and for informational purposes. USE AT YOUR OWN RISK. No warranty is offered or implied here.
A little background on this: I have an old Seagate NAS that only uses SMB1 and is not update-able and no longer supported.
I know the vulnerabilities of SMBv1 and that I will have to replace it eventually. But, for now, I just want to access
my files and don't want to deal with copying over the terabytes of data to a new NAS.

This script is something I put together so I can quickly toggle enabling this protocol when I need to access the drive and disabling when I'm done.

## A few notes:
- This script checks the current state and then prompts whether you want to toggle it.
- If it is **not** enabled and you choose to enable it, it first calls `Add-WindowsCapability`. See further notes below.
 - It then enables the parent feature using `Enable-WindowsOptionalFeature` followed by disabling the children features not needed by calling `Disable-WindowsOptionalFeature`. See further notes below.
- It then calls service control manager to configure the LM Workstation and the SMB Protocol
  - _Caveat Emptor_, this is current as of 05/05/2020. MS may change the recommended configuration of LMWS. Check the latest recommended configuration.
 - If SMBv1 is enabled and you choose to disable it, it reverses the enable order and configures the services, then disables the parent feature. Since all items are to be disabled no need to call individual disables.

## Why Add then Enable?
This is because I found that Microsoft has changed the way this works a few times. Originally, you could just enable the feature through `sc.exe` and configure LMWS. But this changed to requiring to setting the features. Then (and I could be wrong, I didn't spend a lot of time finding out why), it seems that an update forced the removal of the feature.

In any case, `Add-WindowsCapability` ensures the feature exists in case it has been removed as `Enable-WindowsOptionalFeature` will fail if it does not exist.

## Why the Enable all then Disable children?
I had hoped that I could just call `Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol-Client`, but PS returned an error indicating that the parent group had to be enabled to enable children. Since for my purposes I only want the client, I am disabling the others. Especially the -Deprecation child as I want manual control (for now) of this.
But this is a good example of choosing which sub-features to allow or not. Modify to your needs.

## More
I tried to have this apply without a restart, but it isn't possible. Not on my workstation anyway. But note that the system changes that require a restart have this suppressed until the last. This is needed to prevent it from prompting on each step. I will prompt at the end and on restart, the toggle takes effect.

## Running the script
Save the file to a location accessible to an admin account and with elevated permissions execute ./{_fileName_}.ps1. You will need to allow scripts to be run and information on this can be found at [https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7).