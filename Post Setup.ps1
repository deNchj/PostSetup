# Created by deNch
# deNch PostSetup (WIP)
# Use Example:
# Enabled Tweak "Function", 
# Disabled Tweak #"Function",

$tweaks = @(
### Require Administrator ###
"RequireAdmin",
"CustomWindow",
"deNchLogo",

### Post Setup ###
"MinimalProcesses",

### Power Plan ###
"PowerPlanNotif",
"SystemPowerPlan",
"ScreenTimeout",

### TCP Optimizer ###
"NetworkOptiNotif",
"GeneralSettings",
"AdvancedSettings",
"NaglesAlgorithm",

### Firewall ###
"WinFirewallNotif",
"GlobalFirewallSet",
"InboundWin10Firewall",
"OutboundWin10Firewall",

### Scheduled Tasks ###
"WinTasksNotif",
"DisableWin10SchedTasks",

### Services ###
"DisableWin10Services",

### SFC Scannow Run ###
#"RunSFCScannow",

### Compact OS ###
#"RunCompactOS",

### Auxiliary Functions ###
"WaitForKey",
"Restart"
)

##########
# Require Administrator
##########

# Relaunch the Script with Administrator Privileges.
Function RequireAdmin {
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
Exit
cls
}
}

# Launch the Script with A Custom Windows Size.
Function CustomWindow {
powershell -command "[console]::windowwidth=75; [console]::windowheight=25; [console]::bufferwidth=[console]::windowwidth"
}

##########
# Post Setup
##########

# Tells Windows to Stop Splitting Background Services (Requires Restart)
Function MinimalProcesses {
$ram = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1kb
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value $ram -Force
}

##########
# Power Plan
##########
Function PowerPlanNotif {
Write-Host "Configuring PowerPlan" -ForegroundColor Cyan
}

# Setting High Performance Power Plan
Function SystemPowerPlan {
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null

# Primary NVMe Idle Timeout
powercfg -attributes 0012ee47-9041-4b5d-9b77-535fba8b1442 d639518a-e56d-4345-8af2-b9f32fb26109 -ATTRIB_HIDE
# Secondary NVMe Idle Timeout
powercfg -attributes 0012ee47-9041-4b5d-9b77-535fba8b1442 d3d55efd-c1ff-424e-9dc3-441be7833010 -ATTRIB_HIDE
# Turn off hard disk after
powercfg -attributes 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e -ATTRIB_HIDE
# Maximum Power Level
powercfg -attributes 0012ee47-9041-4b5d-9b77-535fba8b1442 51dea550-bb38-4bc4-991b-eacf37be5ec8 -ATTRIB_HIDE

# USB 3 Link Power Mangement
powercfg -attributes 2a737441-1930-4402-8d77-b2bebba308a3 d4e98f31-5ffe-4ce1-be31-1b38b384c009 -ATTRIB_HIDE
# USB selective suspend setting
powercfg -attributes 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 -ATTRIB_HIDE
# Hub Selective Suspend Timeout
powercfg -attributes 2a737441-1930-4402-8d77-b2bebba308a3 0853a681-27c8-4100-a2fd-82013e970683 -ATTRIB_HIDE
}

# Disable Display and Sleep Modes
Function ScreenTimeout {
powercfg /X monitor-timeout-ac 0 | Out-Null
powercfg /X monitor-timeout-dc 0 | Out-Null
powercfg /X standby-timeout-ac 0 | Out-Null
powercfg /X standby-timeout-dc 0 | Out-Null
}

##########
# TCP Optimizer
##########
Function NetworkOptiNotif {
Write-Host "Configuring Network" -ForegroundColor Cyan
}

# General Settings Tab
Function GeneralSettings {
Set-NetTCPSetting -settingname internet -autotuninglevellocal normal #TCP Window Auto-Tuning
Set-NetTCPSetting -settingname internet -scalingheuristics disabled #Windows Scaling Heuristics
Set-NetTCPSetting -settingname internet -ecncapability disabled #ECN Capability
Set-NetTCPSetting -settingname internet -timestamps disabled #TCP 1323 Timestamps
Set-NetOffloadGlobalSetting -Chimney disabled #TCP Chimney Offload
Set-NetOffloadGlobalSetting -receivesidescaling enabled #Receive-Side Scaling (RSS)
Set-NetOffloadGlobalSetting -receivesegmentcoalescing disabled #R.Segment Coalescing (RSC)

Enable-NetAdapterChecksumOffload -name "*" #Checksum Offloading
Disable-NetAdapterLso -name "*" #Large Send Offload (LSO)

netsh interface ipv4 set subinterface "Ethernet" mtu=1500 store=persistent | Out-Null #MTU IPV4
netsh interface ipv6 set subinterface "Ethernet" mtu=1500 store=persistent | Out-Null #MTU IPV6
netsh int tcp set supplemental internet congestionprovider=ctcp | Out-Null #Congestion Control Provider
netsh int tcp set supplemental internetcustom congestionprovider=ctcp | Out-Null #Congestion Control Provider
netsh int tcp set supplemental datacentercustom congestionprovider=ctcp | Out-Null #Congestion Control Provider
netsh int tcp set supplemental compat congestionprovider=ctcp | Out-Null #Congestion Control Provider
netsh int tcp set supplemental datacenter congestionprovider=ctcp | Out-Null #Congestion Control Provider

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "DefaultTTL" -Type Dword -Value 64 #Time to Live (TTL)
}

# Advanced Settings Tab
Function AdvancedSettings {
#Internet Explorer Optimization
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER" -Name "explorer.exe" -Type Dword -Value 10 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER" -Name "iexplorer.exe" -Type Dword -Value 10 -Force
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER" -Name "explorer.exe" -Type Dword -Value 10 -Force
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER" -Name "iexplorer.exe" -Type Dword -Value 10 -Force
#Host Resolution Priority
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" -Name "LocalPriority" -Type DWord -Value 4
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" -Name "HostsPriority" -Type DWord -Value 5
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" -Name "DnsPriority" -Type DWord -Value 6
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" -Name "NetbtPriority" -Type DWord -Value 7
#Gaming Tweak - Network Throttling Index
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 4294967295
#Gaming Tweak - Disable Nagle's Algorithm
If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters")) {
New-Item -Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters" | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters" -Name "TCPNoDelay" -Type Dword -Value 1
#Retransmissions
Set-NetTCPSetting -settingname internet -maxsynretransmissions 2
Set-NetTCPSetting -settingname internet -nonsackrttresiliency disabled
#Retransmit Timeout (RTO)
Set-NetTCPSetting -settingname internet -initialrto 2000
Set-NetTCPSetting -settingname internet -minrto 300
#Type/Quality of Service
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched")) {
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched" | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched" -Name "NonBestEffortlimit" -Type Dword -Value 0
If (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS")) {
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS" | Out-Null
}
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS" -Name "Do not use NLA" -Type String -Value 1
#Network Memory Allocation
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "Size" -Type DWord -Value 3
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "IRPStackSize" -Type DWord -Value 20
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "LargeSystemCache" -Type DWord -Value 1
#Dynamic Port Allocation
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "MaxUserPort" -Type DWord -Value 65534
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpTimedWaitDelay" -Type DWord -Value 30
}

# Disable Nagle's Algorithm
Function NaglesAlgorithm {
$NetworkIDS = @(
(Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\*").PSChildName
)
foreach ($NetworkID in $NetworkIDS) {
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$NetworkID" -Name "TcpAckFrequency" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$NetworkID" -Name "TCPNoDelay" -Type DWord -Value 1
}
}

##########
# Firewall
##########
Function WinFirewallNotif {
Write-Host "Configuring Firewall" -ForegroundColor Cyan
}

# Global Firewall Config
Function GlobalFirewallSet {
Set-NetFirewallProfile -NotifyOnListen False -AllowUnicastResponseToMulticast False
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
}

# Firewall Configuration 
# Set-NetFirewallRule -DisplayName '' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Function InboundWin10Firewall {
If ([System.Environment]::OSVersion.Version.Build -eq 19045) {
$errpref = $ErrorActionPreference #save actual preference
$ErrorActionPreference = "silentlycontinue"
Set-NetFirewallRule -DisplayName '@%SystemRoot%' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@peerdistsh.dll' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@%SystemRoot%\system32\icsvc.dll,-701' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@%SystemRoot%\system32\icsvc.dll,-703' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@%SystemRoot%\system32\icsvc.dll,-705' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@%SystemRoot%\system32\icsvc.dll,-707' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@%SystemRoot%\system32\icsvc.dll,-709' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@%systemroot%\system32\provsvc.dll,-200' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@%systemroot%\system32\provsvc.dll,-205' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@FirewallAPI.dll,-80201' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@FirewallAPI.dll,-80206' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@peerdistsh.dll,-10000' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@peerdistsh.dll,-10002' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@peerdistsh.dll,-10004' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'AllJoyn Router (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'AllJoyn Router (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'App Installer' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'BranchCache Content Retrieval (HTTP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'BranchCache Hosted Cache Server (HTTP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'BranchCache Peer Discovery (WSD-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Cast to Device functionality (qWave-TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Cast to Device functionality (qWave-UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Cast to Device SSDP Discovery (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Cast to Device streaming server (HTTP-Streaming-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Cast to Device streaming server (RTCP-Streaming-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Cast to Device streaming server (RTSP-Streaming-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Cast to Device UPnP Events (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Connected Devices Platform - Wi-Fi Direct Transport (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Connected Devices Platform (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Connected Devices Platform (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Core Networking - Destination Unreachable (ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Core Networking - Destination Unreachable Fragmentation Needed (ICMPv4-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Core Networking - Dynamic Host Configuration Protocol (DHCP-In)' -Direction Inbound -Enabled True -Action Allow -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Dynamic Host Configuration Protocol for IPv6(DHCPV6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Core Networking - Internet Group Management Protocol (IGMP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Core Networking - IPHTTPS (TCP-In)' -Direction Inbound -Enabled True -Action Allow -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - IPv6 (IPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Multicast Listener Done (ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Multicast Listener Query (ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Multicast Listener Report (ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Multicast Listener Report v2 (ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Neighbor Discovery Advertisement (ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Neighbor Discovery Solicitation (ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Packet Too Big (ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Parameter Problem (ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Router Advertisement (ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Router Solicitation (ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Teredo (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Time Exceeded (ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking Diagnostics - ICMP Echo Request (ICMPv4-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Core Networking Diagnostics - ICMP Echo Request (ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Cortana' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Delivery Optimization (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Delivery Optimization (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Desktop App Web Viewer' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'DIAL protocol server (HTTP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Distributed Transaction Coordinator (RPC)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Distributed Transaction Coordinator (RPC-EPMAP)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Distributed Transaction Coordinator (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (Echo Request - ICMPv4-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (Echo Request - ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (LLMNR-UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (NB-Datagram-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (NB-Name-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (NB-Session-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (SMB-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (Spooler Service - RPC)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (Spooler Service - RPC-EPMAP)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing over SMBDirect (iWARP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Groove Music' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'HomeGroup In' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'HomeGroup In (PNRP)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'iSCSI Service (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Key Management Service (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Mail and Calendar' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'mDNS (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Media Center Extenders - HTTP Streaming (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Media Center Extenders - Media Streaming (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Media Center Extenders - qWave (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Media Center Extenders - qWave (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Media Center Extenders - RTSP (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Media Center Extenders - SSDP (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Media Center Extenders - WMDRM-ND/RTP/RTCP (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Media Center Extenders - XSP (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Microsoft Edge' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft Edge (mDNS-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft Photos' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft Solitaire Collection' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft Sticky Notes' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft Store' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Movies & TV' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Netlogon Service (NP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Netlogon Service Authz (RPC)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (LLMNR-UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (NB-Datagram-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (NB-Name-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (Pub-WSD-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (SSDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (UPnP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (WSD Events-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (WSD EventsSecure-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (WSD-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (UPnP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery for Teredo (SSDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Network Discovery for Teredo (UPnP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'OneNote' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Performance Logs and Alerts (DCOM-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Performance Logs and Alerts (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Proximity sharing over TCP (TCP sharing-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Assistance (DCOM-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Assistance (PNRP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Assistance (RA Server TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Assistance (SSDP TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Assistance (SSDP UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Assistance (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Desktop - Shadow (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Desktop - User Mode (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Desktop - User Mode (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Desktop - (TCP-WS-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Desktop - (TCP-WSS-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Event Log Management (NP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Remote Event Log Management (RPC)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Remote Event Log Management (RPC-EPMAP)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Remote Event Monitor (RPC)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Remote Event Monitor (RPC-EPMAP)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Remote Scheduled Tasks Management (RPC)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Remote Scheduled Tasks Management (RPC-EPMAP)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Remote Service Management (NP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Remote Service Management (RPC)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Remote Service Management (RPC-EPMAP)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Inbound Rule for Remote Shutdown (RPC-EP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Inbound Rule for Remote Shutdown (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Remote Volume Management - Virtual Disk Service (RPC)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Remote Volume Management - Virtual Disk Service Loader (RPC)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Remote Volume Management (RPC-EPMAP)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Routing and Remote Access (GRE-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Routing and Remote Access (L2TP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Routing and Remote Access (PPTP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Secure Socket Tunneling Protocol (SSTP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Skype' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'SNMP Trap Service (UDP In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Start' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'TPM Virtual Smart Card Management (DCOM-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'TPM Virtual Smart Card Management (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Virtual Machine Monitoring (DCOM-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Virtual Machine Monitoring (Echo Request - ICMPv4-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Virtual Machine Monitoring (Echo Request - ICMPv6-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Virtual Machine Monitoring (NB-Session-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Virtual Machine Monitoring (RPC)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wi-Fi Direct Network Discovery (In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wi-Fi Direct Scan Service Use (In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wi-Fi Direct Spooler Use (In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Collaboration Computer Name Registration Service (PNRP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Collaboration Computer Name Registration Service (SSDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Defender Firewall Remote Management (RPC)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Defender Firewall Remote Management (RPC-EPMAP)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Management Instrumentation (ASync-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Management Instrumentation (DCOM-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Management Instrumentation (WMI-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Media Player x86 (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (HTTP-Streaming-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (qWave-TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (qWave-UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (SSDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (Streaming-UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (UPnP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Peer to Peer Collaboration Foundation (PNRP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Peer to Peer Collaboration Foundation (SSDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Peer to Peer Collaboration Foundation (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Peer to Peer Collaboration Foundation (WSD-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Remote Management - Compatibility Mode (HTTP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Search' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Security' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wireless Display (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wireless Display Infrastructure Back Channel (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wireless Portable Devices (SSDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wireless Portable Devices (UPnP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'WFD ASP Coordination Protocol (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'WFD Driver-only (TCP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'WFD Driver-only (UDP-In)' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Work or school account' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Xbox' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Xbox Game Bar' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Your account' -Direction Inbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
$ErrorActionPreference = $errpref #restore previous preference
}
}

# Outbound Firewall Configuration 
# Set-NetFirewallRule -DisplayName '' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Function OutboundWin10Firewall {
If ([System.Environment]::OSVersion.Version.Build -eq 19045) {
$errpref = $ErrorActionPreference #save actual preference
$ErrorActionPreference = "silentlycontinue"
Set-NetFirewallRule -DisplayName '@%systemroot%' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@peerdistsh.dll' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@%systemroot%\system32\provsvc.dll,-203' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@%systemroot%\system32\provsvc.dll,-207' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@FirewallAPI.dll,-80204' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@peerdistsh.dll,-10001' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@peerdistsh.dll,-10003' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@peerdistsh.dll,-10005' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '@peerdistsh.dll,-10006' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName '3D Viewer' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'AllJoyn Router (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'AllJoyn Router (UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'App Installer' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'BranchCache Content Retrieval (HTTP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'BranchCache Hosted Cache Client (HTTP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'BranchCache Hosted Cache Server(HTTP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'BranchCache Peer Discovery (WSD-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Captive Portal Flow' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Cast to Device functionality (qWave-TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Cast to Device functionality (qWave-UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Cast to Device streaming server (RTP-Streaming-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Cloud Identity (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Connected Devices Platform - Wi-Fi Direct Transport (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Connected Devices Platform (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Connected Devices Platform (UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Core Networking - DNS (UDP-Out)' -Direction Outbound -Enabled True -Action Allow -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Dynamic Host Configuration Protocol (DHCP-Out)' -Direction Outbound -Enabled True -Action Allow -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Dynamic Host Configuration Protocol for IPv6(DHCPV6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Group Policy (LSASS-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Group Policy (NP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Group Policy (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Internet Group Management Protocol (IGMP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - IPHTTPS (TCP-Out)' -Direction Outbound -Enabled True -Action Allow -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - IPv6 (IPv6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Multicast Listener Done (ICMPv6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Multicast Listener Query (ICMPv6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Multicast Listener Report (ICMPv6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Multicast Listener Report v2 (ICMPv6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Neighbor Discovery Advertisement (ICMPv6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Neighbor Discovery Solicitation (ICMPv6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Packet Too Big (ICMPv6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Parameter Problem (ICMPv6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Router Advertisement (ICMPv6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Router Solicitation (ICMPv6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking - Teredo (UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Core Networking - Time Exceeded (ICMPv6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Core Networking Diagnostics - ICMP Echo Request (ICMPv4-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Core Networking Diagnostics - ICMP Echo Request (ICMPv6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Cortana' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Desktop App Web Viewer' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Connected User Experiences and Telemetry' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Distributed Transaction Coordinator (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Email and accounts' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Feedback Hub' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (Echo Request - ICMPv4-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (Echo Request - ICMPv6-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (LLMNR-UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (NB-Datagram-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (NB-Name-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (NB-Session-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'File and Printer Sharing (SMB-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Get Help' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Groove Music' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'HomeGroup Out' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'HomeGroup Out (PNRP)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'iSCSI Service (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Mail and Calendar' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'mDNS (UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Media Center Extenders - Device Provisioning (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Media Center Extenders - Device Validation (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Media Center Extenders - Media Streaming (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Media Center Extenders - Media Streaming (UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Media Center Extenders - qWave (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Media Center Extenders - qWave (UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Media Center Extenders - RTSP (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Media Center Extenders - Service (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Media Center Extenders - SSDP (UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Media Center Extenders - UPnP (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Media Center Extenders - WMDRM-ND/RTP/RTCP (UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft Content' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft Edge' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft family features' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft Pay' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft People' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft Photos' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft Solitaire Collection' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft Sticky Notes' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft Store' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Microsoft Tips' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Mixed Reality Portal' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Movies & TV' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'MSN Weather' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Narrator' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'NcsiUwpApp' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Network Discovery (LLMNR-UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (NB-Datagram-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (NB-Name-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (Pub WSD-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (SSDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (UPnPHost-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (UPnP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (WSD Events-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (WSD EventsSecure-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Network Discovery (WSD-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Office' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'OneNote' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Paint 3D' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Proximity sharing over TCP (TCP sharing-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Recommended Troubleshooting Client (HTTP/HTTPS Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Assistance (PNRP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Assistance (RA Server TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Assistance (SSDP TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Assistance (SSDP UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Remote Assistance (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Routing and Remote Access (GRE-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Routing and Remote Access (L2TP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Routing and Remote Access (PPTP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Skype' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Start' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Store Experience Host' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Take a Test' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'TPM Virtual Smart Card Management (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wi-Fi Direct Network Discovery (Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wi-Fi Direct Scan Service Use (Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wi-Fi Direct Spooler Use (Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Camera' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Collaboration Computer Name Registration Service (PNRP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Collaboration Computer Name Registration Service (SSDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Default Lock Screen' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Defender SmartScreen' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Device Management Certificate Installer (TCP out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Device Management Device Enroller (TCP out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Device Management Enrollment Service (TCP out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Device Management Sync Client (TCP out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Feature Experience Pack' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Management Instrumentation (WMI-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Maps' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player (UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player x86 (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player x86 (UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (HTTP-Streaming-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (qWave-TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (qWave-UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (SSDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (Streaming-TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (Streaming-UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (UPnPHost-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Media Player Network Sharing Service (UPnP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Windows Peer to Peer Collaboration Foundation (PNRP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Peer to Peer Collaboration Foundation (SSDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Peer to Peer Collaboration Foundation (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Peer to Peer Collaboration Foundation (WSD-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Search' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Security' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Windows Shell Experience' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wireless Display (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Wireless Display (UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wireless Portable Devices (SSDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wireless Portable Devices (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wireless Portable Devices (UPnPHost-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Wireless Portable Devices (UPnP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'WFD ASP Coordination Protocol (UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'WFD Driver-only (TCP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'WFD Driver-only (UDP-Out)' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null 
Set-NetFirewallRule -DisplayName 'Work or school account' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Xbox' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Xbox Game Bar' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Xbox Game Bar Plugin' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Xbox Game UI' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Xbox Identity Provider' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Xbox TCUI' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Your account' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
Set-NetFirewallRule -DisplayName 'Your Phone' -Direction Outbound -Enabled True -Action Block -ErrorAction SilentlyContinue | Out-Null
$ErrorActionPreference = $errpref #restore previous preference
}
}

##########
# Scheduled Tasks
##########
Function WinTasksNotif {
Write-Host "Configuring Tasks" -ForegroundColor Cyan
}

Function DisableWin10SchedTasks {
If ([System.Environment]::OSVersion.Version.Build -eq 19045) {
$errpref = $ErrorActionPreference #save actual preference
$ErrorActionPreference = "silentlycontinue"
Disable-ScheduledTask -TaskName "\MicrosoftEdgeUpdateTaskMachineCore" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "\MicrosoftEdgeUpdateTaskMachineUA" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64 Critical" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 Critical" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Active Directory Rights Management Services Client\AD RMS Rights Policy Template Management (Automated)" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Active Directory Rights Management Services Client\AD RMS Rights Policy Template Management (Manual)" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\AppID\EDP Policy Manager" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\AppID\PolicyConverter" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\AppID\VerifiedPublisherCertStoreCheck" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\PcaPatchDbTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\StartupAppTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\ApplicationData\appuriverifierdaily" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\ApplicationData\appuriverifierinstall" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\ApplicationData\CleanupTemporaryState" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\ApplicationData\DsSvcCleanup" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\AppListBackup\Backup" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\AppxDeploymentClient\Pre-staged app cleanup" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\BitLocker\BitLocker Encrypt All Drives" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\BitLocker\BitLocker MDM policy Refresh" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Bluetooth\UninstallDeviceTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\BrokerInfrastructure\BgTaskRegistrationMaintenanceTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\CertificateServicesClient\AikCertEnrollTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\CertificateServicesClient\CryptoPolicyTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\CertificateServicesClient\KeyPreGenTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\CertificateServicesClient\SystemTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\CertificateServicesClient\UserTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\CertificateServicesClient\UserTask-Roam" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Chkdsk\ProactiveScan" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Chkdsk\SyspartRepair" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Clip\License Validation" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Clip\LicenseImdsIntegration" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Data Integrity Scan\Data Integrity Check And Scan" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Data Integrity Scan\Data Integrity Scan" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Data Integrity Scan\Data Integrity Scan for Crash Recovery" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Defrag\ScheduledDefrag" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Device Information\Device" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Device Information\Device User" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Device Setup\Metadata Refresh" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DeviceDirectoryClient\HandleCommand" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DeviceDirectoryClient\HandleWnsCommand" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DeviceDirectoryClient\IntegrityCheck" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DeviceDirectoryClient\LocateCommandUserSession" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceAccountChange" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceLocationRightsChange" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePeriodic24" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePolicyChange" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceProtectionStateChange" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DeviceDirectoryClient\RegisterDeviceSettingChange" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DeviceDirectoryClient\RegisterUserDevice" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Diagnosis\RecommendedTroubleshootingScanner" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Diagnosis\Scheduled" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DirectX\DirectXDatabaseUpdater" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DirectX\DXGIAdapterCache" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskCleanup\SilentCleanup" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskFootprint\Diagnostics" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskFootprint\StorageSense" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\DUSM\dusmtask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\EDP\EDP App Launch Task" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\EDP\EDP Auth Task" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\EDP\EDP Inaccessible Credentials Task" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\EDP\StorageCardEncryption Task" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\ExploitGuard\ExploitGuard MDM policy Refresh" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\File Classification Infrastructure\Property Definition Sync" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\FileHistory\File History (maintenance mode)" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Flighting\FeatureConfig\ReconcileFeatures" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Flighting\FeatureConfig\UsageDataFlushing" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Flighting\FeatureConfig\UsageDataReporting" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Flighting\OneSettings\RefreshCache" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\HelloFace\FODCleanupTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Input\LocalUserSyncDataAvailable" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Input\MouseSyncDataAvailable" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Input\PenSyncDataAvailable" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Input\TouchpadSyncDataAvailable" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\InstallService\ScanForUpdates" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\InstallService\ScanForUpdatesAsUser" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\InstallService\SmartRetry" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\InstallService\WakeUpAndContinueUpdates" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\InstallService\WakeUpAndScanForUpdates" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\International\Synchronize Language Settings" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\LanguageComponentsInstaller\Installation" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\LanguageComponentsInstaller\ReconcileLanguageResources" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\LanguageComponentsInstaller\Uninstallation" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\License Manager\TempSignedLicenseExchange" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Location\Notifications" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Location\WindowsActionDialog" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Maintenance\WinSAT" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Management\Autopilot\DetectHardwareChange" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Management\Autopilot\RemediateHardwareChange" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Management\Provisioning\Cellular" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Management\Provisioning\Logon" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Management\Provisioning\Retry" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Management\Provisioning\RunOnReboot" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Maps\MapsToastTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Maps\MapsUpdateTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\MUI\LPRemove" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Multimedia\SystemSoundsService" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\NetTrace\GatherNetworkInfo" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\NlaSvc\WiFiTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Offline Files\Background Synchronization" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Offline Files\Logon Synchronization" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\PI\Secure-Boot-Update" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\PI\Sqm-Tasks" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Plug and Play\Device Install Group Policy" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Plug and Play\Device Install Reboot Required" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Plug and Play\Sysprep Generalize Drivers" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Printing\EduPrintProv" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Printing\PrinterCleanupTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\PushToInstall\LoginCheck" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\PushToInstall\Registration" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Ras\MobilityManager" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\RecoveryEnvironment\VerifyWinRE" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Registry\RegIdleBackup" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\RetailDemo\CleanupOfflineContent" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Servicing\StartComponentCleanup" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\SettingSync\BackgroundUploadTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\SettingSync\NetworkStateChangeTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\SharedPC\Account Cleanup" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Shell\CreateObjectTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Shell\FamilySafetyMonitor" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Shell\FamilySafetyRefreshTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Shell\IndexerAutomaticMaintenance" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Shell\ThemesSyncedImageDownload" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Shell\UpdateUserPictureTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTaskLogon" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\SoftwareProtectionPlatform\SvcRestartTaskNetwork" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\SpacePort\SpaceAgentTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\SpacePort\SpaceManagerTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Speech\SpeechModelDownloadTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\StateRepository\MaintenanceTasks" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Storage Tiers Management\Storage Tiers Management Initialization" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Storage Tiers Management\Storage Tiers Optimization" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Subscription\EnableLicenseAcquisition" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Subscription\LicenseAcquisition" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Sysmain\HybridDriveCachePrepopulate" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Sysmain\HybridDriveCacheRebalance" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Sysmain\ResPriStaticDbSync" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Sysmain\WsSwapAssessmentTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\SystemRestore\SR" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Task Manager\Interactive" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Time Synchronization\ForceSynchronizeTime" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Time Synchronization\SynchronizeTime" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Time Zone\SynchronizeTimeZone" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\TPM\Tpm-HASCertRetr" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\TPM\Tpm-Maintenance" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\UNP\RunUpdateNotificationMgr" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\UpdateOrchestrator\Report policies" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\UpdateOrchestrator\Schedule Scan" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\UpdateOrchestrator\Schedule Scan Static Task" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\UpdateOrchestrator\Schedule Wake To Work" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\UpdateOrchestrator\Schedule Work" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\UpdateOrchestrator\UpdateModelTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\UPnP\UPnPHostConfig" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\USB\Usb-Notifications" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\User Profile Service\HiveUploadTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\WaaSMedic\PerformRemediation" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\WCM\WiFiTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\WDI\ResolutionHost" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Defender\Windows Defender Verification" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Filtering Platform\BfeOnServiceStartTypeChange" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Media Sharing\UpdateLibrary" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\WindowsColorSystem\Calibration Loader" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\WindowsUpdate\Scheduled Start" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Wininet\CacheTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\WlanSvc\CDSSync" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\WOF\WIM-Hash-Management" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\WOF\WIM-Hash-Validation" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Work Folders\Work Folders Logon Synchronization" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Work Folders\Work Folders Maintenance Work" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Workplace Join\Automatic-Device-Join" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Workplace Join\Device-Sync" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\Workplace Join\Recovery-Check" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\WwanSvc\NotificationTask" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\Windows\WwanSvc\OobeDiscovery" -ErrorAction SilentlyContinue | Out-Null
Disable-ScheduledTask -TaskName "Microsoft\XblGameSave\XblGameSaveTask" -ErrorAction SilentlyContinue | Out-Null
$ErrorActionPreference = $errpref #restore previous preference
}
}

##########
# Services
##########

# Disabling Un Nessessary Services (Requires Restart)
Function DisableWin10Services {
Write-Host "Configuring Services" -ForegroundColor Cyan
If ([System.Environment]::OSVersion.Version.Build -eq 19045) {
$errpref = $ErrorActionPreference #save actual preference
$ErrorActionPreference = "silentlycontinue"
Stop-Service "" -WarningAction SilentlyContinue
Set-Service "" -StartupType Disabled

$ErrorActionPreference = $errpref #restore previous preference
}
}

##########
# Compact OS
##########

# Run Compact OS 
Function RunCompactOS {
compact /compactos:always
}

##########
# SFC Scannow
##########

# Run SFC Scannow for Repair 
Function RunSFCScannow {
sfc /scannow
}

##########
# Auxiliary Functions
##########

# Wait for Key Press
Function WaitForKey {
Write-Host "Press Any Key to Reboot...                                               " -ForegroundColor White
[Console]::ReadKey($true) | Out-Null
}

# Restart Computer
Function Restart {
Write-Host "Glitch...REBOOT                                                            " -ForegroundColor Cyan
Restart-Computer
}

##########
# Parse Parameters and Apply Tweaks
##########

# Call the Desired Tweak Functions
$tweaks | ForEach { Invoke-Expression $_ }