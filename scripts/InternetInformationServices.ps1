#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

Import-Module ServerManager

[string[]] $Features = @(
    "WAS"
    "Web-WebServer"
    "Web-Common-Http"
    "Web-Health"
    "Web-ISAPI-Ext"
    "Web-ISAPI-Filter"
    "Web-Performance"
    "Web-Security"
    "Web-Mgmt-Console"
    "Web-Mgmt-Service"
    "Web-Scripting-Tools"
)

echo "Installing IIS..."
Add-WindowsFeature -Name $Features | Out-Null
