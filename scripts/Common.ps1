#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

# Exit statuses
[int] $ERROR_SUCCESS_REBOOT_INITIATED = 1641

# Extract the specified zip file to the specified target directory
function Extract-ZipArchive($ArchiveFile, $TargetDirectory) {
    if (!(Test-Path $TargetDirectory)) {
        New-Item -ItemType Directory $TargetDirectory >$null
    }

    $Shell   = New-Object -Com Shell.Application
    $Archive = $Shell.Namespace($ArchiveFile)
    $Target  = $Shell.Namespace($TargetDirectory)

    $Target.CopyHere($Archive.Items())
}

# Does the specified value exist within the registry?
function Test-RegistryValue($RegistryKey, $ValueName) {
    $Exists = Get-ItemProperty -Path $RegistryKey -Name $ValueName `
                               -ErrorAction SilentlyContinue

    if (($Exists -ne $null) -and ($Exists.Length -ne 0)) {
        return $true
    }

    return $false
}
