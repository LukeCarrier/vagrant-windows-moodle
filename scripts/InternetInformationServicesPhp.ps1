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

$Php56IniSource           = (Join-Path $ScriptDir "InternetInformationServicesPhp.ini")
$Php56Zip                 = (Join-Path $CacheDir "php-5.6.19-nts-vc11-x86.zip")
$Php56ExtensionFreetdsZip = (Join-Path $CacheDir "DBLIB_NOTS.zip")

$Php56Dir              = (Join-Path $PhpDir         "5.6")
$Php56Ini              = (Join-Path $Php56Dir       "php.ini")
$Php56Extension        = (Join-Path $Php56Dir       "ext")
$Php56ExtensionFreetds = (Join-Path $Php56Extension "php_dblib.dll")

Write-Host "Enabling CGI in IIS..."
Add-WindowsFeature "Web-CGI" >$null

# Install PHP Manager, but copy the installation media to the local drive first
# as the package will fail to install otherwise. I don't know why this works.
Write-Host "Installing PHP Manager for IIS..."
$Package = (Join-Path $CacheDir "PHPManagerForIIS-1.2.0-x64.msi")
$TempPackage = [System.IO.Path]::GetTempFileName()
Copy-Item $Package $TempPackage
Start-Process -Wait "msiexec" -ArgumentList "/i $TempPackage /qn"
Remove-Item -Force $TempPackage

Write-Host "Creating common parent directory for PHP versions..."
if (!(Test-Path $PhpDir)) {
    New-Item "$PhpDir" -Type Directory >$null
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

Write-Host "Installing PHP 5.6..."
if (!(Test-Path $Php56Dir)) {
    Extract-ZipArchive $Php56Zip $Php56Dir
}

Write-Host "Installing FreeTDS..."
if (!(Test-Path $Php56ExtensionFreetds)) {
    Extract-ZipArchive $Php56ExtensionFreetdsZip $Php56Extension
}

Write-Host "Installing customised php.ini..."
Copy-Item $Php56IniSource $Php56Ini

Write-Host "Registering PHP 5.6 with IIS..."
Add-PSSnapin PHPManagerSnapin
New-PHPVersion -ScriptProcessor (Join-Path $Php56Dir "php-cgi.exe")
