
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

Get-NetRoute

Get-NetIPConfiguration​

Get-NetIPInterface -AddressFamily IPv4 | Select-Object ifIndex, InterfaceAlias, ConnectionState, InterfaceMetric, AutomaticMetric | Format-Table


Get-NetIPAddress -AddressFamily IPv4 |
Where-Object {
    $_.IPAddress -notlike '127.*' -and
    $_.IPAddress -notlike '169.254.*'
} |
Select-Object IPAddress, InterfaceAlias, InterfaceIndex | Format-Table


Set-NetIPInterface -InterfaceAlias "Ethernet1" -InterfaceMetric 10
Set-NetIPInterface -InterfaceAlias "Ethernet2" -InterfaceMetric 20

​
- Helps prioritize interfaces
- Does not guarantee symmetric routing

2. Keep gateway only on primary NIC:

Remove the default gateway (route) from that interface

Remove-NetRoute -DestinationPrefix 0.0.0.0/0 -InterfaceAlias "Ethernet1" -Confirm:$false

Why this works

In Windows:

The “default gateway” is just a route:

0.0.0.0/0 → next hop

So:

Removing the gateway = removing that route

Safer version (if multiple routes exist)

If there are multiple default routes:

Get-NetRoute -DestinationPrefix 0.0.0.0/0 -InterfaceAlias "Ethernet1" | Remove-NetRoute -Confirm:$false

Verify

Get-NetRoute -DestinationPrefix 0.0.0.0/0

You should now see:

NO default route for Ethernet1

Alternative (rebuild cleanly)

If you want to fully reset the interface:

Remove-NetIPAddress -InterfaceAlias "Ethernet1" -Confirm:$false

Then re-add IP without gateway:

New-NetIPAddress -InterfaceAlias "Ethernet1" -IPAddress 10.10.0.174 -PrefixLength 24

​
3. Strong Host Model Configuration
​
Set-NetIPInterface -InterfaceAlias "Ethernet1" -WeakHostSend Disabled
Set-NetIPInterface -InterfaceAlias "Ethernet1" -WeakHostReceive Disabled
​
- Improves interface-specific behavior
​
4. Static Routes (if needed)
​
C:\> New-NetRoute -DestinationPrefix 0.0.0.0/0 -InterfaceAlias "Ethernet2" -NextHop <gateway>

5. Flush everything

ipconfig /release
ipconfig /renew
ipconfig /flushdns

6. Test per interface
ping -S <Fixed_IP> <destination>

ping -S 10.10.1.30 8.8.8.8


###### Reset the whole Windows Server network configuration

## LEVEL 1 — Clean routing + metrics (safe reset)

Remove all custom routes

Get-NetRoute | Where-Object {$_.DestinationPrefix -ne "127.0.0.0/8"} | Remove-NetRoute -Confirm:$false

Reset interface metrics

Get-NetIPInterface | Set-NetIPInterface -AutomaticMetric Enabled

Reset gateways (keep only one)

Get-NetIPConfiguration

Restart adapters

Get-NetAdapter | Restart-NetAdapter

## LEVEL 2 — Reset IP configuration (clean rebuild)

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


## Installing Web-Server (IIS) server role

Enable-PSRemoting -Force

# If needed to manually enable
Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"
Enable-NetFirewallRule -Name "WINRM-HTTPS-In-TCP"

Get-Service WinRM

Get-ChildItem WSMan:\localhost\Listener

Test-WSMan localhost

Install-WindowsFeature -Name Web-Server -IncludeManagementTools

Get-WindowsFeature -Name Web-Server

Get-Service -Name W3SVC

Get-NetTCPConnection -State Listen

Test-NetConnection -ComputerName localhost -Port 5985
Test-NetConnection -ComputerName localhost -Port 80
Test-NetConnection -ComputerName localhost -Port 3389

Get-NetTCPConnection -State Listen | Where-Object {
    $_.LocalPort -in 5985,5986,80,443,3389
} | Select-Object LocalAddress,LocalPort,OwningProcess

Get-NetFirewallRule | Where-Object {$_.Enabled -eq "True"}

Get-NetConnectionProfile

Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

New-NetFirewallRule -DisplayName "Allow ICMPv4" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow

New-NetFirewallRule -DisplayName "Allow HTTP" -Protocol TCP -LocalPort 80 -Direction Inbound -Action Allow

New-NetFirewallRule -DisplayName "Allow HTTPS" -Protocol TCP -LocalPort 443 -Direction Inbound -Action Allow

New-NetFirewallRule -DisplayName "Allow HTTPS" `
  -Direction Inbound `
  -Protocol TCP `
  -LocalPort 443 `
  -Profile Domain,Private `
  -Action Allow

Get-NetFirewallRule -DisplayName "Allow HTTPS"

New-NetFirewallRule -DisplayName "Allow All" -Direction Inbound -Action Allow -Protocol Any



### Setting OpenStack Flex VM with multiple Floating IPs with Allowed-Address-Pairs method

1) Create Ports

openstack port list --server <VM_NAME>

openstack port create \
  --network <PRIVATE_NET> \
  --fixed-ip subnet=<SUBNET_ID>,ip-address=10.10.0.209 \
  <port_name>

2) Add allowed address pairs

openstack port set <PORT_ID> \
  --allowed-address ip-address=10.10.0.243 \
  --allowed-address ip-address=10.10.0.57 \
  --allowed-address ip-address=10.10.0.231

2) Add secondary IPs in Windows Server

New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress 10.10.0.243 -PrefixLength 32
New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress 10.10.0.57 -PrefixLength 32
New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress 10.10.0.231 -PrefixLength 32
New-NetIPAddress `
  -InterfaceAlias "Ethernet0" `
  -IPAddress 10.10.0.209 `
  -PrefixLength 24 `
  -DefaultGateway 10.10.0.1


3) Verify IPs

Get-NetIPAddress -InterfaceAlias "Ethernet0"

4) Associate Floating IPs

openstack floating ip set <FIP1> --port <PORT_ID> --fixed-ip-address 10.10.0.209
openstack floating ip set <FIP2> --port <PORT_ID> --fixed-ip-address 10.10.0.243
openstack floating ip set <FIP3> --port <PORT_ID> --fixed-ip-address 10.10.0.57
openstack floating ip set <FIP4> --port <PORT_ID> --fixed-ip-address 10.10.0.231

5) Windows Defender Firewall configuration

New-NetFirewallRule -DisplayName "Allow ICMP" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
New-NetFirewallRule -DisplayName "Allow HTTP" -Protocol TCP -LocalPort 80 -Direction Inbound -Action Allow
New-NetFirewallRule -DisplayName "Allow HTTPS" -Protocol TCP -LocalPort 443 -Direction Inbound -Action Allow

6) Test configuration

Test-NetConnection <FIP> -Port 443


