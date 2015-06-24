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
$RootPath            = "\\10.0.2.2\lukecarrier-moodle"
$DataPath            = (Join-Path $RootPath "data")
$WebSitePhysicalPath = (Join-Path $RootPath "src")

# Create the database
Write-Host "Creating database Moodle..."
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
$Server = New-Object Microsoft.SqlServer.Management.SMO.Server("(local)\SQLExpress")
$Server.ConnectionContext.ApplicationName = "Vagrant"
if (!($Server.Databases.Contains($DatabaseName))) {
    $Database = New-Object Microsoft.SqlServer.Management.SMO.Database($Server,
                                                                       $DatabaseName)

    # All properties of this database are modelled after those recommended in
    # the Moodle documentation:
    #
    # https://docs.moodle.org/27/en/Installing_MSSQL_for_PHP
    $Database.AnsiNullsEnabled          = $true
    $Database.Collation                 = "Latin1_General_CS_AS"
    $Database.IsReadCommittedSnapshotOn = $true
    $Database.QuotedIdentifiersEnabled  = $true

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

# Tweak the file permissions so reads and writes work
Write-Host "[Experimental] working on file permissions..."
Start-Process -Wait "icacls" -ArgumentList "$RootPath /t /inheritance:r"
Start-Process -Wait "icacls" -ArgumentList "$RootPath /t /grant IUSR:(OI)(CI)(F)"
Start-Process -Wait "icacls" -ArgumentList "$RootPath /t /grant IIS_IUSRS:(OI)(CI)(F)"
