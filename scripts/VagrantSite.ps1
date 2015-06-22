#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

# The documentation, which is crazy difficult to locate
#     https://technet.microsoft.com/en-us/library/ee790599.aspx

# Import IIS administration module
Import-Module WebAdministration

# Base paths
$IisAppPoolPath = (Join-Path "IIS:" "AppPools")
$IisWebSitePath = (Join-Path "IIS:" "Sites")

# Configuration
$AppPoolName         = "VagrantAppPool"
$AppPoolPath         = (Join-Path $IisAppPoolPath $AppPoolName)
$WebSiteName         = "Vagrant"
$WebSitePath         = (Join-Path $IisWebSitePath $WebSiteName)
$WebSitePhysicalPath = "\\10.0.2.2\lukecarrier-moodle-src"

# Create the database

# Create the IIS application pool
Write-Host "Creating application pool..."
if (!(Test-Path $AppPoolPath)) {
    New-WebAppPool $AppPoolName
}
Set-ItemProperty -Path $AppPoolPath -Name managedRuntimeVersion ""
Set-ItemProperty -Path $AppPoolPath -Name processModel.idleTimeout "00:00:00"

# ...and site
Write-Host "Creating web site..."
if (!(Test-Path $WebSitePath)) {
    New-Website $WebSiteName -Port 80 -PhysicalPath $WebSitePhysicalPath `
                -ApplicationPool $AppPoolName
}
