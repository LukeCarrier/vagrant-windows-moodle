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

# Base paths
$IisAppPoolPath = (Join-Path "IIS:" "AppPools")
$IisWebSitePath = (Join-Path "IIS:" "Sites")

# Defaults
$DefaultAppPoolName         = "DefaultAppPool"
$DefaultAppPoolPath         = (Join-Path $IisAppPoolPath $DefaultAppPoolName)
$DefaultWebSiteName         = "Default Web Site"
$DefaultWebSitePath         = (Join-Path $IisWebSitePath $DefaultWebSiteName)
$DefaultWebSitePhysicalPath = (Join-Path (Join-Path "C:" "inetpub") "wwwroot")

echo "Installing IIS..."
Add-WindowsFeature -Name $Features | Out-Null

# Incremental site ID generation fails if no sites exist, so deleting the
# default site will actually break the WebAdministration module. Disable
# incremental site ID generation because it seems like a stupid idea anyway.
#
# such enterprise. very money. wow.
# http://forums.iis.net/post/1912421.aspx
echo "Disabling incremental site ID generation..."
Set-ItemProperty -Path HKLM:\Software\Microsoft\Inetmgr\Parameters `
                 -Name IncrementalSiteIDCreation -Value 0

# Delete the default junk
echo "Removing default pool and site (if present)..."
if (Test-Path $DefaultAppPoolPath) {
    Remove-WebAppPool $DefaultAppPoolName
}
if (Test-Path $DefaultWebSitePath) {
    Remove-Website $DefaultWebSiteName
}
