#!/usr/bin/env python3
"""
Pydantic v2 Schema Validator for Corporate Multi-Branch Network Automation.
Validates VLAN ranges (1-4094), Subnets, Dual ISP Gateways, and WireGuard configurations.
"""

import sys
import ipaddress
from pathlib import Path
from typing import List, Optional, Literal
import yaml
from pydantic import BaseModel, Field, field_validator


class WANInterface(BaseModel):
    name: str
    description: str
    ip: str
    gateway: str
    bandwidth: str
    role: Literal["primary", "backup"]

    @field_validator("ip")
    @classmethod
    def validate_ip(cls, v: str) -> str:
        ipaddress.IPv4Interface(v)
        return v

    @field_validator("gateway")
    @classmethod
    def validate_gw(cls, v: str) -> str:
        ipaddress.IPv4Address(v)
        return v


class VLANModel(BaseModel):
    id: int = Field(..., ge=1, le=4094, description="VLAN ID must be 1-4094")
    name: str
    network: str
    gateway: str
    gateway_ip: str
    dhcp_range: str
    description: str
    protect_from_staff: Optional[bool] = False
    block_internet: Optional[bool] = False
    guest_only: Optional[bool] = False
    qos_priority: Optional[int] = Field(default=None, ge=1, le=8)

    @field_validator("network")
    @classmethod
    def validate_network(cls, v: str) -> str:
        ipaddress.IPv4Network(v, strict=True)
        return v

    @field_validator("gateway")
    @classmethod
    def validate_gateway(cls, v: str) -> str:
        ipaddress.IPv4Interface(v)
        return v


class WireGuardPeer(BaseModel):
    name: str
    public_key: str
    allowed_ips: str
    remote_subnet: str
    endpoint_address: Optional[str] = None
    endpoint_port: Optional[int] = None
    persistent_keepalive: Optional[int] = 25

    @field_validator("remote_subnet")
    @classmethod
    def validate_remote_sub(cls, v: str) -> str:
        ipaddress.IPv4Network(v, strict=True)
        return v


class WireGuardConfig(BaseModel):
    role: Literal["server", "client"]
    interface: str
    listen_port: int = Field(..., ge=1024, le=65535)
    tunnel_ip: str
    private_key: str
    peers: List[WireGuardPeer]

    @field_validator("tunnel_ip")
    @classmethod
    def validate_tunnel_ip(cls, v: str) -> str:
        ipaddress.IPv4Interface(v)
        return v


class CorporateRouterModel(BaseModel):
    hostname: str
    site_name: str
    site_prefix: str
    wan_interfaces: List[WANInterface]
    lan_bridge: str
    trunk_interfaces: List[str]
    vlans: List[VLANModel]
    wireguard: WireGuardConfig

    @field_validator("site_prefix")
    @classmethod
    def validate_site_prefix(cls, v: str) -> str:
        ipaddress.IPv4Network(v, strict=True)
        return v


def main():
    workspace = Path(__file__).resolve().parent.parent
    host_vars_dir = workspace / "inventory" / "host_vars"

    files = sorted(host_vars_dir.glob("*.yml"))
    if not files:
        print(f"❌ Error: No YAML files found in {host_vars_dir}")
        sys.exit(1)

    has_errors = False
    print(f"🔍 Validating {len(files)} corporate router data model(s) with Pydantic v2...\n")

    for file_path in files:
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                raw_data = yaml.safe_load(f)

            model = CorporateRouterModel(**raw_data)
            print(
                f"✅ {file_path.name}: Validated! (Site: {model.site_name}, "
                f"Prefix: {model.site_prefix}, VLANs: {len(model.vlans)}, "
                f"WANs: {len(model.wan_interfaces)})"
            )
        except Exception as e:
            print(f"❌ {file_path.name}: Validation Failed!\n   {e}\n")
            has_errors = True

    if has_errors:
        print("💥 Schema validation failed for one or more files.")
        sys.exit(1)
    else:
        print("\n🎉 All corporate data models passed validation successfully!")


if __name__ == "__main__":
    main()
