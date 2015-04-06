#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

Param(
    # Where our scripts end up.
    #
    # This can differ based upon the host environment, particularly when we're
    # just testing deploys.
    [String] $VagrantScriptsDir
)

Invoke-Expression -Command (Join-Path $VagrantScriptsDir "Install.ps1")

echo "Provisioning complete"
