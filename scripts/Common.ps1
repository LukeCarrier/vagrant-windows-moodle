#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

# Exit statuses
[int] $ERROR_SUCCESS_REBOOT_INITIATED = 1641

# Does the specified value exist within the registry?
function Test-RegistryValue($regkey, $name) {
    $Exists = Get-ItemProperty -Path $regkey -Name $name `
                               -ErrorAction SilentlyContinue

    if (($Exists -ne $null) -and ($Exists.Length -ne 0)) {
        return $true
    }

    return $false
}
