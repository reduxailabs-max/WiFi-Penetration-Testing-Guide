#!/bin/bash
################################################################################
# NETWORK DIAGRAM GENERATOR
# Analyzes recon output and generates ASCII/network diagrams
# Usage: ./diagram-generator.sh <recon-output-directory>
################################################################################

set -euo pipefail

RECON_DIR="${1:-}"
OUTPUT_FILE="network-diagram.md"

if [[ -z "$RECON_DIR" || ! -d "$RECON_DIR" ]]; then
    echo "Usage: $0 <recon-output-directory>"
    echo "Example: $0 network-recon-20250419-120000"
    exit 1
fi

cat > "$OUTPUT_FILE" << 'HEADER'
# Network Topology Analysis

_Generated from reconnaissance data_

---

## 1. Executive Summary

This document contains the discovered network topology based on enumeration data.

HEADER

# Main execution
main() {
    parse_local
    parse_routing
    generate_topology
    generate_vlan_analysis
    generate_attack_surface
    echo ""
    echo "[+] Diagram generated: $OUTPUT_FILE"
}

main
