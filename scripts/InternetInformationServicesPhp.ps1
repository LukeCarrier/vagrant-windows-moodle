#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$CacheDir  = (Join-Path (Split-Path $ScriptDir) "cache")

$PhpDir = "C:\PHP"

$Php55IniSource           = (Join-Path $ScriptDir "InternetInformationServicesPhp.ini")
$Php55Zip                 = (Join-Path $CacheDir "php-5.5.24-nts-vc11-x86.zip")
$Php55ExtensionFreetdsZip = (Join-Path $CacheDir "DBLIB_NOTS.zip")

$Php55Dir              = (Join-Path $PhpDir         "5.5")
$Php55Ini              = (Join-Path $Php55Dir       "php.ini")
$Php55Extension        = (Join-Path $Php55Dir       "ext")
$Php55ExtensionFreetds = (Join-Path $Php55Extension "php_dblib.dll")

Write-Host "Enabling CGI in IIS..."
Add-WindowsFeature "Web-CGI" | Out-Null

Write-Host "Installing PHP Manager for IIS..."
$Package = (Join-Path $CacheDir PHPManagerForIIS-1.2.0-x64.msi)
Start-Process -Wait "msiexec" -ArgumentList "/i $Package /qn"

Write-Host "Creating common parent directory for PHP versions..."
if (!(Test-Path $PhpDir)) {
    New-Item "$PhpDir" -Type Directory > $null
}

if (!(Test-Path "$env:WinDir\system32\msvcr110.dll")) {
    [String[]] $Redistributables = @("x86", "x64")

    foreach ($Architecture in $Redistributables) {
        Write-Host "Installing Visual C++ 11 redistributable ($Architecture)..."
        $InstallerPath = (Join-Path $CacheDir "vcredist_$Architecture.exe")
        Start-Process -Wait $InstallerPath `
                      -ArgumentList "/passive /norestart"
    }

    Exit $ERROR_SUCCESS_REBOOT_INITIATED
}

Write-Host "Installing PHP 5.5..."
if (!(Test-Path $Php55Dir)) {
    New-Item "$Php55Dir" -Type Directory > $null

    Extract-ZipArchive $Php55Zip $Php55Dir
}

Write-Host "Installing FreeTDS..."
if (!(Test-Path $Php55ExtensionFreetds)) {
    Extract-ZipArchive $Php55ExtensionFreetdsZip $Php55Extension
}

Write-Host "Installing customised php.ini..."
Copy-Item $Php55IniSource $Php55Ini

Write-Host "Registering PHP 5.5 with IIS..."
Add-PSSnapin PHPManagerSnapin
New-PHPVersion -ScriptProcessor (Join-Path $Php55Dir "php-cgi.exe")
