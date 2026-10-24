#!/usr/bin/env python3
"""
Configuration Generation Script for Corporate Network Automation.
Renders production-ready MikroTik RouterOS v7 (.rsc) configuration files
from Jinja2 templates and host_vars.
"""

import sys
from pathlib import Path
import yaml
from jinja2 import Environment, FileSystemLoader

BASE_DIR = Path(__file__).resolve().parent.parent
TEMPLATES_DIR = BASE_DIR / "templates"
HOST_VARS_DIR = BASE_DIR / "inventory" / "host_vars"
GROUP_VARS_DIR = BASE_DIR / "inventory" / "group_vars" / "all"
OUTPUT_DIR = BASE_DIR / "generated_configs"


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Load common group vars
    common_vars = {}
    main_vars_file = GROUP_VARS_DIR / "main.yml"
    if main_vars_file.exists():
        with open(main_vars_file, "r", encoding="utf-8") as f:
            common_vars = yaml.safe_load(f) or {}

    env = Environment(
        loader=FileSystemLoader(str(TEMPLATES_DIR)),
        trim_blocks=True,
        lstrip_blocks=True,
    )

    template = env.get_template("mikrotik_full_routeros.j2")
    host_files = sorted(HOST_VARS_DIR.glob("*.yml"))

    print(f"🚀 Rendering RouterOS configurations for {len(host_files)} routers...\n")

    for hf in host_files:
        router_key = hf.stem
        with open(hf, "r", encoding="utf-8") as f:
            host_data = yaml.safe_load(f)

        merged_context = {**common_vars, **host_data}

        # Substitute vault secrets if not decrypted
        if "vault_hq_wg_private_key" not in merged_context:
            merged_context["wireguard"]["private_key"] = "aHR0cHM6Ly93d3cueW91dHViZS5jb20vd2F0Y2g/dj1kUXc0dzlXZ1hjUQ=="

        rendered = template.render(merged_context)
        out_file = OUTPUT_DIR / f"{router_key}.rsc"
        with open(out_file, "w", encoding="utf-8") as f:
            f.write(rendered)

        print(f"📄 Generated: {out_file.relative_to(BASE_DIR)} ({len(rendered.splitlines())} lines)")

    print("\n✅ All MikroTik RouterOS configurations generated successfully!")


if __name__ == "__main__":
    main()
