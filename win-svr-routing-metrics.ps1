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
​
2. Strong Host Model Configuration
​
C:\> Set-NetIPInterface -InterfaceAlias "Ethernet1" -WeakHostSend Disabled
C:\> Set-NetIPInterface -InterfaceAlias "Ethernet1" -WeakHostReceive Disabled
​
- Improves interface-specific behavior
​
3. Static Routes
​
C:\> New-NetRoute -DestinationPrefix 0.0.0.0/0 -InterfaceAlias "Ethernet2" -NextHop <gateway>
