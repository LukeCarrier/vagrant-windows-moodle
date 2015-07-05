#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

# The documentation, which is crazy difficult to locate
#     https://technet.microsoft.com/en-us/library/ee790599.aspx

# Import IIS and SQL Server administration modules
Import-Module WebAdministration

# For running sqlps
$ScriptDir       = Split-Path $script:MyInvocation.MyCommand.Path
$SqlServerScript = (Join-Path $ScriptDir "VagrantSiteSqlServer.ps1")

# Base paths
$IisAppPoolPath = (Join-Path "IIS:" "AppPools")
$IisWebSitePath = (Join-Path "IIS:" "Sites")

# IIS configuration
$AppPoolName         = "VagrantAppPool"
$AppPoolPath         = (Join-Path $IisAppPoolPath $AppPoolName)
$WebSiteName         = "Vagrant"
$WebSitePath         = (Join-Path $IisWebSitePath $WebSiteName)
$RootPath            = "\\10.0.2.2\lukecarrier-moodle"
$DataPath            = (Join-Path $RootPath "data")
$WebSitePhysicalPath = (Join-Path $RootPath "src")

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

# Fiddle with SQL Server
sqlps -Command "&{ . $SqlServerScript }"

# Tweak the file permissions so reads and writes work
Write-Host "[Experimental] working on file permissions..."
Start-Process -Wait "icacls" -ArgumentList "$RootPath /t /inheritance:r"
Start-Process -Wait "icacls" -ArgumentList "$RootPath /t /grant IUSR:(OI)(CI)(F)"
Start-Process -Wait "icacls" -ArgumentList "$RootPath /t /grant IIS_IUSRS:(OI)(CI)(F)"
