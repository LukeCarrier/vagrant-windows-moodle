#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

# Activate Windows
#Invoke-Expression -Command (Join-Path $ScriptDir "ActivateWindows.ps1")

# Install SQL Server Express 2008 R2
Invoke-Expression -Command (Join-Path $ScriptDir "SqlServer2008R2.ps1")

# Internet Information Services
Invoke-Expression -Command (Join-Path $ScriptDir "InternetInformationServices.ps1")

# PHP
Invoke-Expression -Command (Join-Path $ScriptDir "InternetInformationServicesPhp.ps1")
