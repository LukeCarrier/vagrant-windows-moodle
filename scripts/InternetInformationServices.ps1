#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

Import-Module ServerManager

echo "Adding Windows Server roles..."
[String[]] $Roles = @(
    "WAS",
    "Web-Common-HTTP",
    "Web-Health",
    "Web-Mgmt-Console",
    "Web-Mgmt-Tools",
    "Web-Performance",
    "Web-Security"
)
foreach ($Role in $Roles) {
    Add-WindowsFeature $Role
}
