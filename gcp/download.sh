#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if [[ "$STATION_STATUS" != "RUNNING" ]]; then
  echo "Station is not running. Run 'station start' to start it"
  exit 1
fi

scp \
  -A \
  -o "UserKnownHostsFile=/dev/null" \
  "${EIRINI_STATION_USERNAME}@${STATION_IP}:$1" "$2"
