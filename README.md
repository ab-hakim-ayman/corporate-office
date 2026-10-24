# 🏢 Corporate Office Network Automation (Multi-Branch NetDevOps)

An enterprise-grade, production-ready NetDevOps automation framework designed for a **2-Branch Corporate Office Network** powered by **MikroTik RouterOS v7**, **Dual ISP Failover**, **Site-to-Site WireGuard VPN**, and **9 Segmented Departmental VLANs**.

---

## 📌 Architecture Highlights

* **Multi-Branch Topology:**
  * **Branch 1 (Head Office / HQ):** Subnet block `10.10.0.0/16` (MikroTik CCR2004)
  * **Branch 2 (Remote Branch):** Subnet block `10.20.0.0/16` (MikroTik RB5009)
* **Dual ISP Redundancy:** Active-Backup with recursive ping monitoring (`8.8.8.8` & `1.1.1.1`), providing sub-3s hitless failover.
* **Site-to-Site VPN:** Hardware-accelerated WireGuard tunnel connecting both branches over the public internet.
* **Network Segmentation (9 VLANs):**
  * `VLAN 10`: Management (Restricted to Network/IT Administrators)
  * `VLAN 20`: Top Management (Executive / C-Level)
  * `VLAN 30`: HR & Accounts (Protected from general staff)
  * `VLAN 40`: Admin & Operations
  * `VLAN 50`: General Staff
  * `VLAN 60`: VoIP Phones (QoS Priority Queue 1)
  * `VLAN 70`: Network Printers
  * `VLAN 80`: CCTV Surveillance & Access Control (**Blocked from Internet**)
  * `VLAN 90`: Guest Wi-Fi / Hotspot (**Client Isolated to Internet Only**)
* **NetDevOps Toolchain:**
  * **NetBox v4.7.3:** Central Source of Truth (DCIM/IPAM)
  * **Pydantic v2:** Automated schema validation
  * **Jinja2:** Declarative RouterOS v7 configuration templating
  * **Ansible:** Dynamic inventory and automated orchestration

---

## 📁 Project Directory Structure

```
corporate-network-automation/
├── README.md                           # Master Architecture and Runbook
├── ansible.cfg                         # Ansible configuration with Vault and RouterOS plugins
├── .vault_pass                         # Secret password file for Ansible Vault
├── .yamllint                           # YAML syntax and code quality rules
│
├── inventory/
│   ├── hosts.ini                       # Multi-branch static inventory
│   ├── netbox.yml                      # NetBox Dynamic Inventory plugin
│   ├── group_vars/
│   │   └── all/
│   │       ├── main.yml                # Global corporate DNS, NTP, domain settings
│   │       └── vault.yml               # AES-256 encrypted router passwords & VPN keys
│   └── host_vars/
│       ├── hq_router.yml               # HQ data model (Dual ISP, 9 VLANs, VPN Server)
│       └── branch2_router.yml          # Branch 2 data model (Dual ISP, 9 VLANs, VPN Client)
│
├── templates/
│   └── mikrotik_full_routeros.j2       # Master MikroTik RouterOS v7 Jinja2 template
│
├── playbooks/
│   ├── deploy_corp.yml                 # Master deployment playbook (generate, backup, push)
│   └── verify_connectivity.yml         # Verification playbook (VPN, routes, pings)
│
├── scripts/
│   ├── netbox_corp_sync.py             # Syncs sites, routers, 9 VLANs, and IPs to NetBox
│   ├── validate_corp_schema.py         # Pydantic v2 schema validation script
│   └── generate_configs.py             # Pre-renders production .rsc files for Winbox
│
└── generated_configs/                  # Production-ready RouterOS .rsc scripts
    ├── hq_router.rsc                   # HQ Router configuration script
    └── branch2_router.rsc              # Branch 2 Router configuration script
```

---

## 📑 IPAM & VLAN Addressing Plan

| Department / Service | VLAN ID | HQ Subnet (Branch 1) | Branch 2 Subnet | Security & Firewall Policy |
| :--- | :--- | :--- | :--- | :--- |
| **Management** | `10` | `10.10.10.0/24` | `10.20.10.0/24` | Only VLAN with Winbox/SSH access to switches and routers. |
| **Top Management** | `20` | `10.10.20.0/24` | `10.20.20.0/24` | Full unrestricted bandwidth and inter-VLAN access. |
| **HR & Accounts** | `30` | `10.10.30.0/24` | `10.20.30.0/24` | Protected: General staff cannot initiate connections here. |
| **Admin & Operations** | `40` | `10.10.40.0/24` | `10.20.40.0/24` | General corporate file servers and internal access. |
| **General Staff** | `50` | `10.10.50.0/24` | `10.20.50.0/24` | Standard internet; blocked from HR and Management. |
| **VoIP / IP Phone** | `60` | `10.10.60.0/24` | `10.20.60.0/24` | **Simple Queue QoS Priority 1/1** (no voice lag). |
| **Printers** | `70` | `10.10.70.0/24` | `10.20.70.0/24` | Reachable from Staff and HR VLANs. |
| **CCTV & Security** | `80` | `10.10.80.0/24` | `10.20.80.0/24` | **Blocked from Internet** (anti-leak protection). |
| **Guest Wi-Fi** | `90` | `10.10.90.0/24` | `10.20.90.0/24` | **Client Isolated**; access to Internet only. |
| **WireGuard VPN** | `wg-corp` | `10.255.255.1/30` | `10.255.255.2/30` | Site-to-Site Encrypted Tunnel (UDP 51820). |

---

## 🚀 Quick Start & Operations Guide

### 1. Validate Data Models
Ensure there are no typos, invalid VLAN IDs, or IP conflicts:
```bash
python3 scripts/validate_corp_schema.py
```

### 2. Synchronize to NetBox (Source of Truth)
Push the multi-branch topology, 18 VLANs, and IP pools to NetBox:
```bash
python3 scripts/netbox_corp_sync.py
```
View the live data at: **[http://localhost:8000](http://localhost:8000)** (User: `admin` / Password: `admin`).

### 3. Generate RouterOS Scripts (.rsc)
Render standalone `.rsc` configuration files:
```bash
python3 scripts/generate_configs.py
```
Output files will be generated in `generated_configs/`:
* `generated_configs/hq_router.rsc`
* `generated_configs/branch2_router.rsc`

### 4. Deploy Configuration via Ansible
Deploy across both routers using Ansible:
```bash
ansible-playbook -i inventory/hosts.ini playbooks/deploy_corp.yml
```
Or dynamically pull live parameters from NetBox:
```bash
ansible-playbook -i inventory/netbox.yml playbooks/deploy_corp.yml
```

### 5. Manual Import via Winbox / CLI (Alternative)
If preferred, you can drag and drop `hq_router.rsc` into MikroTik Winbox **Files** window, open the **Terminal**, and execute:
```routeros
/import file-name=hq_router.rsc
```
The router will configure the entire bridge, 9 VLANs, DHCP servers, dual ISP failover, WireGuard VPN, firewall rules, and Prometheus monitoring in under 10 seconds!

---

## 📊 Observability & Monitoring (Prometheus & Grafana)

The corporate network includes a dedicated observability stack running via Docker Compose:

```bash
# Start Prometheus, Grafana, and MikroTik Exporter
docker compose -f docker-compose.monitoring.yml up -d
```

### 🖥️ Dashboards & Endpoints:
* **Grafana Dashboard:** [http://localhost:3001](http://localhost:3001)
  * **Credentials:** `admin` / `admin`
  * **Auto-Provisioned Dashboard:** `MikroTik Corporate Multi-Branch Network Overview`
  * **Panels Included:**
    * ⚡ **Router Health:** CPU load, RAM usage, Uptime, Exporter status
    * 🌐 **Dual ISP WAN Traffic:** Primary vs Backup ISP bandwidth (RX/TX Mbps) and recursive failover indicators
    * 🏢 **9 Departmental VLANs:** Bandwidth breakdown across HR, Admin, Mgmt, Staff, CCTV, VoIP, and Guest Hotspot
    * 🔒 **WireGuard Site-to-Site VPN:** Tunnel throughput and handshake latency between Dhaka HQ and Chittagong Branch
    * 🛡️ **Security & Conntrack:** NAT Connection tracking utilization and firewall drops
* **Prometheus Targets & Metrics:** [http://localhost:9091](http://localhost:9091)
* **MikroTik Exporter Metrics:** [http://localhost:9436/metrics](http://localhost:9436/metrics)

