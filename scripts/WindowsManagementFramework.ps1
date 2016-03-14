#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$CacheDir  = (Join-Path (Split-Path -Parent $ScriptDir) "cache")
. (Join-Path $ScriptDir "Common.ps1")

$DotNetPackagePath = (Join-Path $CacheDir "dotNetFx40_Full_x86_x64.exe")
if (!(Test-RegistryValue "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client" "Install")) {
    Write-Host "Installing .NET Framework 4.0..."
    Start-Process -Wait -FilePath $DotNetPackagePath -ArgumentList /q, /norestart >$null
}

$WmfPackage = (Join-Path $CacheDir "Windows6.1-KB2506143-x64.msu")
$TempWmfPackage = [System.IO.Path]::GetTempFileName()
if ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Host "Installing Windows Management Framework 3.0..."
    Copy-Item $WmfPackage $TempWmfPackage
    &wusa $TempWmfPackage /quiet /norestart >$null
    Remove-Item -Force $TempWmfPackage

    Exit $ERROR_SUCCESS_REBOOT_INITIATED
}
