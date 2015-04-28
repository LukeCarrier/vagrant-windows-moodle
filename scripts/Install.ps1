#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

$TaskDir = Split-Path $script:MyInvocation.MyCommand.Path
. (Join-Path $TaskDir "Common.ps1")

[string[]] $Tasks = @(
    # Must be first -- upgrades WMF/PS to fix double redirection bug
    "WindowsManagementFramework",

    #"ActivateWindows",
    "SqlServer2008R2",
    "InternetInformationServices",
    "InternetInformationServicesPhp",
    "VagrantSite"
)

foreach ($Task in $Tasks) {
    Write-Host "Running task $Task..."
    $TaskPath = (Join-Path $TaskDir "$Task.ps1")

    &$TaskPath

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
