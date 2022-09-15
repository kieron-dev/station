#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo "Name:   $STATION_NAME"
echo "IP:     $STATION_IP"
echo "Status: $STATION_STATUS"
