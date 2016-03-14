#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

Import-Module ServerManager

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$CacheDir  = (Join-Path (Split-Path $ScriptDir) "cache")

echo "Installing .NET Framework 3.5..."
Add-WindowsFeature AS-NET-Framework >$null

echo "Installing SQL Server 2008 R2 SP2 - Express Edition..."
$InstallerPath = (Join-Path $CacheDir "SQLEXPRADV_x64_ENU.exe")
$ConfigurationFilePath = (Join-Path $ScriptDir "SqlServer2008R2ConfigurationFile.ini")
Start-Process -Wait $InstallerPath `
              -ArgumentList "/ACTION=install /ConfigurationFile=$ConfigurationFilePath"
