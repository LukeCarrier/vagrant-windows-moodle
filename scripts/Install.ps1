#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

# Install SQL Server Express 2008 R2
Invoke-Expression -Command (Join-Path $ScriptDir "SqlServer2008R2.ps1")
