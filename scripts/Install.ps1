#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir "Common.ps1")

[string[]] $Scripts = @(
    # Must be first -- upgrades WMF/PS to fix double redirection bug
    "WindowsManagementFramework",

    #"ActivateWindows",
    "SqlServer2008R2",
    "InternetInformationServices",
    "InternetInformationServicesPhp",
    "VagrantSite"
)

foreach ($Script in $Scripts) {
    $ScriptPath = (Join-Path $ScriptDir "$Script.ps1")

    &$ScriptPath | Out-Host

    # Handle reboots.
    #
    # If the task indicates that it requires a reboot to complete, shut down the
    # VM. The next provisioner in the set (reload) will handle booting it back
    # up, then if necessary another shell provisioner will restart us from
    # Install.ps1.
    if ($LASTEXITCODE -eq $ERROR_SUCCESS_REBOOT_INITIATED) {
        Write-Host "Task requires reboot; exiting for reload plugin..."
        Exit
    }
}
