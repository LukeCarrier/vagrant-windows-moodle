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
$DatabaseName        = "Moodle"
$AppPoolName         = "VagrantAppPool"
$AppPoolPath         = (Join-Path $IisAppPoolPath $AppPoolName)
$WebSiteName         = "Vagrant"
$WebSitePath         = (Join-Path $IisWebSitePath $WebSiteName)
$WebSitePhysicalPath = "\\10.0.2.2\lukecarrier-moodle-src"

# Create the database
Write-Host "Creating database Moodle..."
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
$Server = New-Object Microsoft.SqlServer.Management.SMO.Server("(local)\SQLExpress")
# $Server.ConnectionContext.set_Login("Vagrant")
# $Server.ConnectionContext.set_SecurePassword("Vagrant")
$Server.ConnectionContext.ApplicationName = "Vagrant"
if (!($Server.Databases.Contains($DatabaseName))) {
    $Database = New-Object Microsoft.SqlServer.Management.SMO.Database($Server,
                                                                       $DatabaseName)
    $Database.Create()
}

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
