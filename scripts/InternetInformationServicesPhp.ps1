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

echo "Enabling CGI in IIS..."
Add-WindowsFeature "Web-CGI"

echo "Installing PHP Manager for IIS..."
$Package = (Join-Path $CacheDir PHPManagerForIIS-1.2.0-x64.msi)
Start-Process -Wait "msiexec" -ArgumentList "/i $Package /qn"

echo "Creating common parent directory for PHP versions..."
if (!(Test-Path $PhpDir)) {
    New-Item "$PhpDir" -Type Directory
}

echo "Installing PHP 5.5..."
echo $Php55Zip
echo $Php55Dir
if (!(Test-Path $Php55Dir)) {
    New-Item "$Php55Dir" -Type Directory

    $Shell       = New-Object -Com Shell.Application
    $Archive     = $Shell.Namespace($Php55Zip)
    $Destination = $Shell.Namespace($Php55Dir)

    $Destination.CopyHere($Archive.Items())
}
