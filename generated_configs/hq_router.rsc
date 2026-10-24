# ==============================================================================
# MikroTik RouterOS v7 Production Configuration Script
# Generated automatically via NetDevOps Jinja2 Automation Engine
# Hostname: hq-rtr01 | Site: HQ-Dhaka | Subnet: 10.10.0.0/16
# ==============================================================================

/system identity set name="hq-rtr01"
/system clock set time-zone-name="Asia/Dhaka"

# ------------------------------------------------------------------------------
# 1. Interface Lists
# ------------------------------------------------------------------------------
/interface list add name=WAN
/interface list add name=LAN
/interface list add name=ISOLATED_GUEST

/interface list member add interface=ether1 list=WAN
/interface list member add interface=ether2 list=WAN
/interface list member add interface=bridge-lan list=LAN

# ------------------------------------------------------------------------------
# 2. LAN Bridge & VLAN Setup (vlan-filtering enabled)
# ------------------------------------------------------------------------------
/interface bridge add name=bridge-lan vlan-filtering=yes protocol-mode=rstp

/interface bridge port add bridge=bridge-lan interface=ether3
/interface bridge port add bridge=bridge-lan interface=ether4

# ------------------------------------------------------------------------------
# 3. VLAN Interfaces, IP Addressing, Pools & DHCP Servers
# ------------------------------------------------------------------------------
# --- VLAN 10: Management (Network Infrastructure Management) ---
/interface vlan add interface=bridge-lan name="vlan10-Management" vlan-id=10
/interface list member add interface="vlan10-Management" list=LAN

/ip address add address=10.10.10.1/24 interface="vlan10-Management" comment="Management"
/ip pool add name="pool-vlan10-Management" ranges=10.10.10.50-10.10.10.200
/ip dhcp-server add address-pool="pool-vlan10-Management" interface="vlan10-Management" name="dhcp-vlan10" lease-time=8h disabled=no
/ip dhcp-server network add address=10.10.10.0/24 gateway=10.10.10.1 dns-server=1.1.1.1,8.8.8.8 domain="corp.netdevops.local" comment="Management Network"

# --- VLAN 20: Top-Management (Executive and Board Management) ---
/interface vlan add interface=bridge-lan name="vlan20-Top-Management" vlan-id=20
/interface list member add interface="vlan20-Top-Management" list=LAN

/ip address add address=10.10.20.1/24 interface="vlan20-Top-Management" comment="Top-Management"
/ip pool add name="pool-vlan20-Top-Management" ranges=10.10.20.50-10.10.20.200
/ip dhcp-server add address-pool="pool-vlan20-Top-Management" interface="vlan20-Top-Management" name="dhcp-vlan20" lease-time=8h disabled=no
/ip dhcp-server network add address=10.10.20.0/24 gateway=10.10.20.1 dns-server=1.1.1.1,8.8.8.8 domain="corp.netdevops.local" comment="Top-Management Network"

# --- VLAN 30: HR-Accounts (HR and Financial Accounting) ---
/interface vlan add interface=bridge-lan name="vlan30-HR-Accounts" vlan-id=30
/interface list member add interface="vlan30-HR-Accounts" list=LAN

/ip address add address=10.10.30.1/24 interface="vlan30-HR-Accounts" comment="HR-Accounts"
/ip pool add name="pool-vlan30-HR-Accounts" ranges=10.10.30.50-10.10.30.200
/ip dhcp-server add address-pool="pool-vlan30-HR-Accounts" interface="vlan30-HR-Accounts" name="dhcp-vlan30" lease-time=8h disabled=no
/ip dhcp-server network add address=10.10.30.0/24 gateway=10.10.30.1 dns-server=1.1.1.1,8.8.8.8 domain="corp.netdevops.local" comment="HR-Accounts Network"

# --- VLAN 40: Admin-Ops (Administrative Operations) ---
/interface vlan add interface=bridge-lan name="vlan40-Admin-Ops" vlan-id=40
/interface list member add interface="vlan40-Admin-Ops" list=LAN

/ip address add address=10.10.40.1/24 interface="vlan40-Admin-Ops" comment="Admin-Ops"
/ip pool add name="pool-vlan40-Admin-Ops" ranges=10.10.40.50-10.10.40.200
/ip dhcp-server add address-pool="pool-vlan40-Admin-Ops" interface="vlan40-Admin-Ops" name="dhcp-vlan40" lease-time=8h disabled=no
/ip dhcp-server network add address=10.10.40.0/24 gateway=10.10.40.1 dns-server=1.1.1.1,8.8.8.8 domain="corp.netdevops.local" comment="Admin-Ops Network"

# --- VLAN 50: Staff (General Office Staff) ---
/interface vlan add interface=bridge-lan name="vlan50-Staff" vlan-id=50
/interface list member add interface="vlan50-Staff" list=LAN

/ip address add address=10.10.50.1/24 interface="vlan50-Staff" comment="Staff"
/ip pool add name="pool-vlan50-Staff" ranges=10.10.50.50-10.10.50.250
/ip dhcp-server add address-pool="pool-vlan50-Staff" interface="vlan50-Staff" name="dhcp-vlan50" lease-time=8h disabled=no
/ip dhcp-server network add address=10.10.50.0/24 gateway=10.10.50.1 dns-server=1.1.1.1,8.8.8.8 domain="corp.netdevops.local" comment="Staff Network"

# --- VLAN 60: VoIP (IP Telephony and PBX) ---
/interface vlan add interface=bridge-lan name="vlan60-VoIP" vlan-id=60
/interface list member add interface="vlan60-VoIP" list=LAN

/ip address add address=10.10.60.1/24 interface="vlan60-VoIP" comment="VoIP"
/ip pool add name="pool-vlan60-VoIP" ranges=10.10.60.50-10.10.60.200
/ip dhcp-server add address-pool="pool-vlan60-VoIP" interface="vlan60-VoIP" name="dhcp-vlan60" lease-time=8h disabled=no
/ip dhcp-server network add address=10.10.60.0/24 gateway=10.10.60.1 dns-server=1.1.1.1,8.8.8.8 domain="corp.netdevops.local" comment="VoIP Network"

# --- VLAN 70: Printers (Networked Printers & Scanners) ---
/interface vlan add interface=bridge-lan name="vlan70-Printers" vlan-id=70
/interface list member add interface="vlan70-Printers" list=LAN

/ip address add address=10.10.70.1/24 interface="vlan70-Printers" comment="Printers"
/ip pool add name="pool-vlan70-Printers" ranges=10.10.70.10-10.10.70.50
/ip dhcp-server add address-pool="pool-vlan70-Printers" interface="vlan70-Printers" name="dhcp-vlan70" lease-time=8h disabled=no
/ip dhcp-server network add address=10.10.70.0/24 gateway=10.10.70.1 dns-server=1.1.1.1,8.8.8.8 domain="corp.netdevops.local" comment="Printers Network"

# --- VLAN 80: CCTV (CCTV Surveillance & NVR) ---
/interface vlan add interface=bridge-lan name="vlan80-CCTV" vlan-id=80
/interface list member add interface="vlan80-CCTV" list=LAN

/ip address add address=10.10.80.1/24 interface="vlan80-CCTV" comment="CCTV"
/ip pool add name="pool-vlan80-CCTV" ranges=10.10.80.50-10.10.80.200
/ip dhcp-server add address-pool="pool-vlan80-CCTV" interface="vlan80-CCTV" name="dhcp-vlan80" lease-time=8h disabled=no
/ip dhcp-server network add address=10.10.80.0/24 gateway=10.10.80.1 dns-server=1.1.1.1,8.8.8.8 domain="corp.netdevops.local" comment="CCTV Network"

# --- VLAN 90: Guest-Hotspot (Isolated Visitor Guest Wi-Fi) ---
/interface vlan add interface=bridge-lan name="vlan90-Guest-Hotspot" vlan-id=90
/interface list member add interface="vlan90-Guest-Hotspot" list=LAN

/ip address add address=10.10.90.1/24 interface="vlan90-Guest-Hotspot" comment="Guest-Hotspot"
/ip pool add name="pool-vlan90-Guest-Hotspot" ranges=10.10.90.10-10.10.90.250
/ip dhcp-server add address-pool="pool-vlan90-Guest-Hotspot" interface="vlan90-Guest-Hotspot" name="dhcp-vlan90" lease-time=8h disabled=no
/ip dhcp-server network add address=10.10.90.0/24 gateway=10.10.90.1 dns-server=1.1.1.1,8.8.8.8 domain="corp.netdevops.local" comment="Guest-Hotspot Network"

/interface list member add interface="vlan90-Guest-Hotspot" list=ISOLATED_GUEST

# Bridge VLAN Trunk / Tagging Table
/interface bridge vlan add bridge=bridge-lan tagged=ether3,ether4,bridge-lan vlan-ids=10 comment="Management"
/interface bridge vlan add bridge=bridge-lan tagged=ether3,ether4,bridge-lan vlan-ids=20 comment="Top-Management"
/interface bridge vlan add bridge=bridge-lan tagged=ether3,ether4,bridge-lan vlan-ids=30 comment="HR-Accounts"
/interface bridge vlan add bridge=bridge-lan tagged=ether3,ether4,bridge-lan vlan-ids=40 comment="Admin-Ops"
/interface bridge vlan add bridge=bridge-lan tagged=ether3,ether4,bridge-lan vlan-ids=50 comment="Staff"
/interface bridge vlan add bridge=bridge-lan tagged=ether3,ether4,bridge-lan vlan-ids=60 comment="VoIP"
/interface bridge vlan add bridge=bridge-lan tagged=ether3,ether4,bridge-lan vlan-ids=70 comment="Printers"
/interface bridge vlan add bridge=bridge-lan tagged=ether3,ether4,bridge-lan vlan-ids=80 comment="CCTV"
/interface bridge vlan add bridge=bridge-lan tagged=ether3,ether4,bridge-lan vlan-ids=90 comment="Guest-Hotspot"

# ------------------------------------------------------------------------------
# 4. Dual ISP WAN Addressing & NAT
# ------------------------------------------------------------------------------
/ip address add address=203.0.113.2/30 interface=ether1 comment="ISP1-Primary-Fiber (primary)"
/ip address add address=198.51.100.2/30 interface=ether2 comment="ISP2-Backup-Radio (backup)"

/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN comment="NAT Outbound to Internet"

# ------------------------------------------------------------------------------
# 5. Routing Tables & Dual ISP Inbound Symmetry (Mangle)
# ------------------------------------------------------------------------------
# Dedicated FIB Routing Tables for Return Traffic Symmetry
/routing table add name=to_ether1 fib comment="Routing table for ISP1-Primary-Fiber"
/ip route add dst-address=0.0.0.0/0 gateway=203.0.113.1 routing-table=to_ether1 comment="Default return route via ether1"
/routing table add name=to_ether2 fib comment="Routing table for ISP2-Backup-Radio"
/ip route add dst-address=0.0.0.0/0 gateway=198.51.100.1 routing-table=to_ether2 comment="Default return route via ether2"

# Inbound Connection & Routing Marks
/ip firewall mangle
# Mark connections initiating from ether1 to router services
add action=mark-connection chain=input in-interface=ether1 connection-state=new new-connection-mark=ether1_conn passthrough=yes comment="Mark inbound connections on ether1"
add action=mark-routing chain=output connection-mark=ether1_conn new-routing-mark=to_ether1 passthrough=no comment="Route replies back via ether1"

# Mark forwarded connections (e.g. DST-NAT / Port Forwarding)
add action=mark-connection chain=forward in-interface=ether1 connection-state=new new-connection-mark=ether1_fwd passthrough=yes comment="Mark forwarded traffic on ether1"
add action=mark-routing chain=prerouting in-interface-list=LAN connection-mark=ether1_fwd new-routing-mark=to_ether1 passthrough=no comment="Return forwarded traffic via ether1"
# Mark connections initiating from ether2 to router services
add action=mark-connection chain=input in-interface=ether2 connection-state=new new-connection-mark=ether2_conn passthrough=yes comment="Mark inbound connections on ether2"
add action=mark-routing chain=output connection-mark=ether2_conn new-routing-mark=to_ether2 passthrough=no comment="Route replies back via ether2"

# Mark forwarded connections (e.g. DST-NAT / Port Forwarding)
add action=mark-connection chain=forward in-interface=ether2 connection-state=new new-connection-mark=ether2_fwd passthrough=yes comment="Mark forwarded traffic on ether2"
add action=mark-routing chain=prerouting in-interface-list=LAN connection-mark=ether2_fwd new-routing-mark=to_ether2 passthrough=no comment="Return forwarded traffic via ether2"

# ------------------------------------------------------------------------------
# 6. Dual ISP Recursive Failover Routing (Main Table)
# ------------------------------------------------------------------------------
# Primary Target Ping Anchor
/ip route add dst-address=8.8.8.8/32 gateway=203.0.113.1 scope=10 comment="Primary Ping Anchor"
/ip route add dst-address=0.0.0.0/0 gateway=8.8.8.8 check-gateway=ping distance=1 comment="Default Route via Primary ISP (Monitored)"

# Secondary Target Ping Anchor
/ip route add dst-address=1.1.1.1/32 gateway=198.51.100.1 scope=10 comment="Backup Ping Anchor"
/ip route add dst-address=0.0.0.0/0 gateway=1.1.1.1 check-gateway=ping distance=2 comment="Default Route via Backup ISP (Failover)"

# ------------------------------------------------------------------------------
# 7. Site-to-Site WireGuard VPN
# ------------------------------------------------------------------------------
/interface wireguard add listen-port=51820 name=wg-corp private-key="aHR0cHM6Ly93d3cueW91dHViZS5jb20vd2F0Y2g/dj1kUXc0dzlXZ1hjUQ==" comment="Site-to-Site VPN"
/ip address add address=10.255.255.1/30 interface=wg-corp comment="WireGuard Tunnel IP"

/interface wireguard peers add allowed-address="10.255.255.2/32,10.20.0.0/16" endpoint-address="203.0.114.2" endpoint-port=51820 interface=wg-corp public-key="BRANCH2_WG_PUBLIC_KEY_67890=" persistent-keepalive=25s comment="Branch2-Chittagong"
/ip route add dst-address=10.20.0.0/16 gateway=wg-corp comment="Route to Branch2-Chittagong"

# ------------------------------------------------------------------------------
# 8. Enterprise Security & Isolation Firewall Filters
# ------------------------------------------------------------------------------
/ip firewall filter
# FastTrack & State Tracking
add action=accept chain=input connection-state=established,related comment="Accept Established/Related Input"
add action=drop chain=input connection-state=invalid comment="Drop Invalid Input"
add action=accept chain=input protocol=icmp comment="Allow ICMP (Ping)"

# Allow WireGuard VPN Handshakes on WAN
add action=accept chain=input dst-port=51820 protocol=udp in-interface-list=WAN comment="Allow WireGuard Tunnel Inbound"

# Management Protection: Only VLAN 10 (Management) can access Winbox/SSH on router
add action=accept chain=input in-interface="vlan10-Management" comment="Allow Full Admin Access from Management VLAN"

# Observability: Allow SNMP Polling and RouterOS API for Prometheus Scraper
add action=accept chain=input dst-port=161 protocol=udp in-interface-list=LAN comment="Allow SNMP Polling from LAN"
add action=accept chain=input dst-port=8728,8729 protocol=tcp in-interface-list=LAN comment="Allow RouterOS API from LAN"
add action=accept chain=input dst-port=161 protocol=udp in-interface=wg-corp comment="Allow SNMP Polling over WireGuard"
add action=accept chain=input dst-port=8728,8729 protocol=tcp in-interface=wg-corp comment="Allow RouterOS API over WireGuard"

add action=drop chain=input dst-port=22,80,443,8291,8728,8729 protocol=tcp comment="Block Router Services from Other VLANs"


# Forwarding Rules: Established / Related / FastTrack
add action=fasttrack-connection chain=forward connection-state=established,related hw-offload=yes comment="FastTrack"
add action=accept chain=forward connection-state=established,related comment="Accept Established/Related Forward"
add action=drop chain=forward connection-state=invalid comment="Drop Invalid Forward"

# CCTV Security: Completely block CCTV VLAN from Internet access
add action=drop chain=forward in-interface="vlan80-CCTV" out-interface-list=WAN comment="DROP CCTV Outbound to Internet (Anti-Leak)"

# Guest Hotspot Isolation: Block Guests from ALL internal office subnets
add action=drop chain=forward in-interface-list=ISOLATED_GUEST out-interface-list=!WAN comment="DROP Guest Access to Corporate LAN"

# HR & Accounts Protection: General Staff cannot initiate connections to HR
add action=drop chain=forward in-interface="vlan50-Staff" out-interface="vlan30-HR-Accounts" comment="BLOCK Staff to HR/Accounts"

# Allow Inter-VLAN routing for trusted internal services
add action=accept chain=forward in-interface-list=LAN out-interface-list=LAN comment="Allow Internal Corporate Routing"
add action=accept chain=forward in-interface-list=LAN out-interface-list=WAN comment="Allow Corporate Internet"
add action=accept chain=forward in-interface=wg-corp out-interface-list=LAN comment="Allow Inter-Branch VPN Traffic"

# ------------------------------------------------------------------------------
# 9. QoS Priority Queue for VoIP Telephony
# ------------------------------------------------------------------------------
/queue simple add name="VoIP-Priority-Queue" target="vlan60-VoIP" priority=1/1 max-limit=10M/10M comment="VoIP High Priority QoS"

# ------------------------------------------------------------------------------
# 10. Observability, SNMP & Prometheus Monitoring
# ------------------------------------------------------------------------------
# Enable SNMP v2c / v3 for Prometheus Monitoring
/snmp set enabled=yes contact="noc@corp.netdevops.local" location="HQ-Dhaka"
/snmp community add name=corp-monitor addresses=0.0.0.0/0 read-access=yes security=none

# Dedicated Read-Only API User for Prometheus MikroTik Exporter
/user group add name=monitoring policy=read,api,test comment="Read-only monitoring policy"
/user add name=prometheus group=monitoring password="PromMonSecure2026!" comment="Prometheus Exporter Scraper"

# Ensure RouterOS API service is enabled
/ip service enable api

# ------------------------------------------------------------------------------
# Configuration rendered successfully.
# ------------------------------------------------------------------------------
