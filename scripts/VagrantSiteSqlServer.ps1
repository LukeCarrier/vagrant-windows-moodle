#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

# SQL Server configuration
$DatabaseName      = "Moodle"
$DatabaseLogin     = "Moodle"
$DatabasePassword  = ("vagrant" | ConvertTo-SecureString -AsPlainText -Force)
$SqlServerInstance = "SQLEXPRESS"
$EngineService     = 'MSSQL$' + $SqlServerInstance

# Enable TCP/IP protocol -- figure out some URIs...
$MachineUri     = "ManagedComputer[@Name='$env:ComputerName']"
$InstanceUri    = "$MachineUri/ServerInstance[@Name='$SqlServerInstance']"
$TcpProtocolUri = "$InstanceUri/ServerProtocol[@Name='Tcp']"

# ...then enable the protocol...
Write-Host "Enabling TCP/IP for $SqlServerInstance..."
$Machine     = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer
$TcpProtocol = $Machine.GetSmoObject($TcpProtocolUri)
$TcpProtocol.IsEnabled = $true
$TcpProtocol.Alter()

# ...set the port number, we're close now; changes take effect after a restart
Write-Host "Setting IPAll port for $SqlServerInstance..."
$TcpAddressesUri = "$TcpProtocolUri/IPAddress[@Name='IPAll']"
$TcpAddresses = $Machine.GetSmoObject($TcpAddressesUri)
$TcpAddresses.IPAddressProperties[1].Value = "1433"
$TcpProtocol.Alter()

# Connect to the instance
$Server = New-Object Microsoft.SqlServer.Management.Smo.Server("(local)\$SqlServerInstance")
$Server.ConnectionContext.ApplicationName = "Vagrant"

# Enable mixed authentication
Write-Host "Enabling mixed authentication..."
$Server.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Mixed
$Server.Alter()

# Restart to apply changes
Write-Host "Restarting and waiting for $SqlServerInstance to become available..."
Restart-Service $EngineService -Force
$Machine.Services[$EngineService].Refresh()

# Create the login
Write-Host "Creating $DatabaseLogin login..."
try {
    $Login = New-Object Microsoft.SqlServer.Management.Smo.Login($Server, $DatabaseLogin)
    $Login.LoginType                 = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
    $Login.PasswordExpirationEnabled = $false
    $Login.PasswordPolicyEnforced    = $false

    $Login.Create($DatabasePassword)
} catch [System.Management.Automation.MethodInvocationException] {
    # TODO: it probably already existed, but we need to improve handling
}

# Create the database
if (!($Server.Databases.Contains($DatabaseName))) {
    Write-Host "Creating database Moodle..."
    $Database = New-Object Microsoft.SqlServer.Management.Smo.Database($Server,
                                                                       $DatabaseName)

    # All properties of this database are modelled after those recommended in
    # the Moodle documentation:
    #
    # https://docs.moodle.org/27/en/Installing_MSSQL_for_PHP
    $Database.AnsiNullsEnabled          = $true
    $Database.Collation                 = "Latin1_General_CS_AS"
    $Database.IsReadCommittedSnapshotOn = $true
    $Database.QuotedIdentifiersEnabled  = $true

    $Database.Create()
}

Write-Host "Refreshing SMOs..."
$Server.Refresh()

Write-Host "Setting owner $DatabaseLogin for $DatabaseName..."
$Database = $Server.Databases[$DatabaseName]
$Database.SetOwner($DatabaseLogin)
$Database.Alter()
