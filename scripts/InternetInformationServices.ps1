#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$CacheDir  = (Join-Path (Split-Path $ScriptDir) "cache")

Import-Module ServerManager

[string[]] $Features = @(
    "WAS",
    "Web-WebServer",
    "Web-Common-Http",
    "Web-Health",
    "Web-ISAPI-Ext",
    "Web-ISAPI-Filter",
    "Web-Performance",
    "Web-Security",
    "Web-Mgmt-Console",
    "Web-Mgmt-Service",
    "Web-Scripting-Tools"
)

Write-Host "Installing IIS..."
Add-WindowsFeature -Name $Features > $null

# Incremental site ID generation fails if no sites exist, so deleting the
# default site will actually break the WebAdministration module. Disable
# incremental site ID generation because it seems like a stupid idea anyway.
#
# such enterprise. very money. wow.
# http://forums.iis.net/post/1912421.aspx
Write-Host "Disabling incremental site ID generation..."
Set-ItemProperty -Path HKLM:\Software\Microsoft\Inetmgr\Parameters `
                 -Name IncrementalSiteIDCreation -Value 0

# Freshly installed!
Import-Module WebAdministration

# Base paths
$IisAppPoolPath = (Join-Path "IIS:" "AppPools")
$IisWebSitePath = (Join-Path "IIS:" "Sites")

# Defaults
$DefaultAppPoolName         = "DefaultAppPool"
$DefaultAppPoolPath         = (Join-Path $IisAppPoolPath $DefaultAppPoolName)
$DefaultWebSiteName         = "Default Web Site"
$DefaultWebSitePath         = (Join-Path $IisWebSitePath $DefaultWebSiteName)
$DefaultWebSitePhysicalPath = (Join-Path (Join-Path "C:" "inetpub") "wwwroot")

# Delete the default junk
Write-Host "Removing default pool and site (if present)..."
if (Test-Path $DefaultAppPoolPath) {
    Remove-WebAppPool $DefaultAppPoolName
}
if (Test-Path $DefaultWebSitePath) {
    Remove-Website $DefaultWebSiteName
}

# Install the IIS 7.5 UTF-8/FastCGI hotfix

# Because Microsoft are really good at releasing fixes to problems in their
# hyper enterprisey platforms, we can't automate the extraction of the
# self-extracting archive. Instead, we can extract the included update via the
# shell then install that via WUSA.
Write-Host "Installing IIS 7.5 UTF-8 FastCGI hotfix..."
$TempDir               = (Join-Path "C:" "iis-fastcgi-utf8")
$HotfixFilename        = "417240_intl_x64_zip.exe"
$HotfixPath            = (Join-Path $CacheDir $HotfixFilename)
$HotfixArchiveFilename = (Get-Item $HotfixPath).Basename + ".zip"
$HotfixArchivePath     = (Join-Path $TempDir $HotfixArchiveFilename)
$HotfixPackage         = (Join-Path $TempDir "Windows6.1-KB2277918-x64.msu")
if (!(Test-Path $TempDir)) {
    New-Item -Type Directory $TempDir | Out-Null
}
Copy-Item $HotfixPath $HotfixArchivePath
Extract-ZipArchive $HotfixArchivePath $TempDir
&wusa $HotfixPackage /quiet /norestart
#Remove-Item -Recurse -Force $TempDir
