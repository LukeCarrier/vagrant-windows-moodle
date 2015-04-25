#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

# 180 day trial product keys:
#
# Edition      Key
# Web          KBV3Q-DJ8W7-VPB64-V88KG-82C49
# Standard     4GGC4-9947F-FWFP3-78P6F-J9HDR
# Enterprise   7PJBC-63K3J-62TTK-XF46D-W3WMD
# Datacenter   QX7TD-2CMJR-D7WWY-KVCYC-6D2YT
$ProductKey = "4GGC4-9947F-FWFP3-78P6F-J9HDR"

Write-Host "Activating Windows..."
$Service = Get-WmiObject -ComputerName $env:ComputerName `
                         -Query "SELECT * FROM SoftwareLicensingService"
$Service.InstallProductKey($ProductKey)
$Service.RefreshLicenseStatus()
