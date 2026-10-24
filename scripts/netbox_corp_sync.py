#!/usr/bin/env python3
"""
NetBox Corporate Multi-Branch Network Synchronization Script.
Registers Sites, MikroTik Devices, 9 Departmental VLANs, IPAM Subnets,
Dual ISP WAN IPs, and WireGuard VPN parameters into NetBox.
"""

import sys
from pathlib import Path
import yaml
import pynetbox

NETBOX_URL = "http://localhost:8000"
NETBOX_TOKEN = "0123456789abcdef0123456789abcdef01234567"

BASE_DIR = Path(__file__).resolve().parent.parent
HOST_VARS_DIR = BASE_DIR / "inventory" / "host_vars"


def main():
    print(f"Connecting to NetBox at {NETBOX_URL}...")
    nb = pynetbox.api(NETBOX_URL, token=NETBOX_TOKEN)

    # 1. Manufacturer
    mfg = nb.dcim.manufacturers.get(slug="mikrotik") or nb.dcim.manufacturers.create(
        name="MikroTik", slug="mikrotik"
    )
    print(f"✅ Manufacturer: {mfg.name}")

    # 2. Device Types
    dt_ccr = nb.dcim.device_types.get(slug="ccr2004") or nb.dcim.device_types.create(
        model="CCR2004-16G-2S+", slug="ccr2004", manufacturer=mfg.id
    )
    dt_rb = nb.dcim.device_types.get(slug="rb5009") or nb.dcim.device_types.create(
        model="RB5009UG+S+IN", slug="rb5009", manufacturer=mfg.id
    )
    device_types = {"hq-rtr01": dt_ccr, "br2-rtr01": dt_rb}

    # 3. Role
    role_gw = nb.dcim.device_roles.get(slug="gateway-router") or nb.dcim.device_roles.create(
        name="Gateway-Router", slug="gateway-router", color="e91e63"
    )

    # 4. Process each branch host_vars
    for hf in sorted(HOST_VARS_DIR.glob("*.yml")):
        with open(hf, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)

        hostname = data["hostname"]
        site_name = data["site_name"]
        site_slug = site_name.lower().replace(" ", "-")

        # Create Site
        site = nb.dcim.sites.get(slug=site_slug) or nb.dcim.sites.create(
            name=site_name, slug=site_slug, status="active"
        )
        print(f"\n📍 Site: {site.name} ({site.slug})")

        # Register Site Master Prefix (e.g. 10.10.0.0/16 or 10.20.0.0/16)
        site_prefix_str = data["site_prefix"]
        prefix_obj = nb.ipam.prefixes.get(prefix=site_prefix_str) or nb.ipam.prefixes.create(
            prefix=site_prefix_str,
            site=site.id,
            status="active",
            description=f"Corporate Subnet for {site_name}",
        )

        # Create MikroTik Device
        dev = nb.dcim.devices.get(name=hostname)
        if not dev:
            dev = nb.dcim.devices.create(
                name=hostname,
                device_type=device_types.get(hostname, dt_rb).id,
                role=role_gw.id,
                site=site.id,
                status="active",
            )
            print(f"  🖥️  Created Device: {dev.name}")

        dev.local_context_data = data
        dev.save()

        # Create LAN Bridge Interface
        bridge_name = data.get("lan_bridge", "bridge-lan")
        bridge_intf = nb.dcim.interfaces.get(device_id=dev.id, name=bridge_name) or nb.dcim.interfaces.create(
            device=dev.id,
            name=bridge_name,
            type="bridge",
            enabled=True,
        )

        # Register Dual ISP WAN Interfaces & IP addresses
        for wan in data.get("wan_interfaces", []):
            wan_name = wan["name"]
            w_intf = nb.dcim.interfaces.get(device_id=dev.id, name=wan_name) or nb.dcim.interfaces.create(
                device=dev.id,
                name=wan_name,
                type="1000base-t",
                description=f"{wan['description']} ({wan['role']})",
                enabled=True,
            )
            wan_ip = nb.ipam.ip_addresses.get(address=wan["ip"]) or nb.ipam.ip_addresses.create(
                address=wan["ip"],
                assigned_object_type="dcim.interface",
                assigned_object_id=w_intf.id,
                description=f"WAN IP {wan['role'].upper()}",
                status="active",
            )
            print(f"  🌐 WAN {wan_name}: {wan['ip']} ({wan['role']})")

        # Register all 9 VLANs and Subnets
        print("  🏷️  VLANs and IP Pools:")
        for v in data.get("vlans", []):
            vid = v["id"]
            vname = v["name"]

            # NetBox VLAN object
            vlan_obj = nb.ipam.vlans.filter(vid=vid, site_id=site.id)
            vlan_list = list(vlan_obj)
            if not vlan_list:
                vlan = nb.ipam.vlans.create(
                    vid=vid,
                    name=vname,
                    site=site.id,
                    status="active",
                    description=v.get("description", ""),
                )
            else:
                vlan = vlan_list[0]

            # NetBox Prefix object for the VLAN
            v_prefix = nb.ipam.prefixes.get(prefix=v["network"]) or nb.ipam.prefixes.create(
                prefix=v["network"],
                site=site.id,
                vlan=vlan.id,
                status="active",
                description=f"{vname} Subnet",
            )

            # Gateway IP
            gw_ip = nb.ipam.ip_addresses.get(address=v["gateway"]) or nb.ipam.ip_addresses.create(
                address=v["gateway"],
                status="active",
                description=f"Gateway for {vname}",
            )
            print(f"     • VLAN {vid:02d} ({vname:16s}): Subnet {v['network']:15s} Gateway: {v['gateway_ip']}")

        # WireGuard Tunnel Interface & IP
        wg_data = data.get("wireguard", {})
        if wg_data:
            wg_name = wg_data.get("interface", "wg-corp")
            wg_intf = nb.dcim.interfaces.get(device_id=dev.id, name=wg_name) or nb.dcim.interfaces.create(
                device=dev.id,
                name=wg_name,
                type="virtual",
                description="Site-to-Site WireGuard VPN",
                enabled=True,
            )
            wg_ip = nb.ipam.ip_addresses.get(address=wg_data["tunnel_ip"]) or nb.ipam.ip_addresses.create(
                address=wg_data["tunnel_ip"],
                assigned_object_type="dcim.interface",
                assigned_object_id=wg_intf.id,
                description=f"WireGuard Tunnel IP ({wg_data['role']})",
                status="active",
            )
            print(f"  🔒 WireGuard: {wg_name} ({wg_data['tunnel_ip']}) - Role: {wg_data['role'].upper()}")

    print("\n🎉 NetBox Corporate Infrastructure Synchronization Completed Successfully!")


if __name__ == "__main__":
    main()
