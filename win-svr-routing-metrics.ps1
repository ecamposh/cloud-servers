
Windows Server does not natively support policy-based routing equivalent to Linux (ip rule).
​
Behavior
​
Windows uses:
​
- Interface metrics
- Route metrics
​
Routing is still destination-based, not source-based.
​
Impact
​
Same symptoms as Linux:
​
- Only one floating IP works reliably
- Traffic enters via one NIC, exits via another
- NAT becomes asymmetric
​
Mitigation Options
​
1. Adjust Interface Metrics

​
Get-NetIPInterface | Select-Object ifIndex, InterfaceAlias, AddressFamily, ConnectionState | Format-Table


Get-NetIPAddress -AddressFamily IPv4 |
Where-Object {
    $_.IPAddress -notlike '127.*' -and
    $_.IPAddress -notlike '169.254.*'
} |
Select-Object IPAddress, InterfaceAlias, InterfaceIndex | Format-Table


C:\> Set-NetIPInterface -InterfaceAlias "Ethernet1" -InterfaceMetric 10
C:\> Set-NetIPInterface -InterfaceAlias "Ethernet2" -InterfaceMetric 20

​
- Helps prioritize interfaces
- Does not guarantee symmetric routing

2. Keep gateway only on primary NIC:

Set-NetIPConfiguration -InterfaceAlias "Ethernet1" -IPv4DefaultGateway $null
Set-NetIPConfiguration -InterfaceAlias "Ethernet2" -IPv4DefaultGateway $null
Set-NetIPConfiguration -InterfaceAlias "Ethernet3" -IPv4DefaultGateway $null
​
3. Strong Host Model Configuration
​
C:\> Set-NetIPInterface -InterfaceAlias "Ethernet1" -WeakHostSend Disabled
C:\> Set-NetIPInterface -InterfaceAlias "Ethernet1" -WeakHostReceive Disabled
​
- Improves interface-specific behavior
​
4. Static Routes
​
C:\> New-NetRoute -DestinationPrefix 0.0.0.0/0 -InterfaceAlias "Ethernet2" -NextHop <gateway>

5. Test per interface
Test-NetConnection <destination> -SourceAddress <IP>


###### Reset the whole Windows Server network configuration

LEVEL 1 — Clean routing + metrics (safe reset)

Remove all custom routes

Get-NetRoute | Where-Object {$_.DestinationPrefix -ne "127.0.0.0/8"} | Remove-NetRoute -Confirm:$false

Reset interface metrics

Get-NetIPInterface | Set-NetIPInterface -AutomaticMetric Enabled

Reset gateways (keep only one)

Get-NetIPConfiguration

Then:

Set-NetIPConfiguration -InterfaceAlias "Ethernet1" -IPv4DefaultGateway $null
Set-NetIPConfiguration -InterfaceAlias "Ethernet2" -IPv4DefaultGateway $null
Set-NetIPConfiguration -InterfaceAlias "Ethernet3" -IPv4DefaultGateway $null

Restart adapters

Get-NetAdapter | Restart-NetAdapter

LEVEL 2 — Reset IP configuration (clean rebuild)

Remove all IP addresses

Get-NetIPAddress -AddressFamily IPv4 | Remove-NetIPAddress -Confirm:$false

Enable DHCP (temporary reset)

Get-NetIPInterface | Set-NetIPInterface -Dhcp Enabled

Flush everything

ipconfig /release
ipconfig /renew
ipconfig /flushdns

At this point:

Networking is “factory default” (DHCP-based)


