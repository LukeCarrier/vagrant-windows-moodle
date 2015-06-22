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
$Php55Dir = (Join-Path $PhpDir "5.5")

$Php55Zip = (Join-Path $CacheDir "php-5.5.24-nts-vc11-x86.zip")

Write-Host "Enabling CGI in IIS..."
Add-WindowsFeature "Web-CGI" | Out-Null

Write-Host "Installing PHP Manager for IIS..."
$Package = (Join-Path $CacheDir PHPManagerForIIS-1.2.0-x64.msi)
Start-Process -Wait "msiexec" -ArgumentList "/i $Package /qn"

Write-Host "Creating common parent directory for PHP versions..."
if (!(Test-Path $PhpDir)) {
    New-Item "$PhpDir" -Type Directory > $null
}

[String[]] $Redistributables = @("x86", "x64")
if (!(Test-Path "$env:WinDir\system32\msvcr110.dll")) {
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

    $Shell       = New-Object -Com Shell.Application
    $Archive     = $Shell.Namespace($Php55Zip)
    $Destination = $Shell.Namespace($Php55Dir)

    $Destination.CopyHere($Archive.Items())
}

Write-Host "Registering PHP 5.5 with IIS..."
Add-PSSnapin PHPManagerSnapin
New-PHPVersion -ScriptProcessor (Join-Path $Php55Dir "php-cgi.exe")
