#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo "Provisioning $EIRINI_STATION_USERNAME-eirini-station"
scp -r ~/workspace/eirini-station/provision*.sh "$EIRINI_STATION_USERNAME@$STATION_IP:/tmp"
ssh -A "$EIRINI_STATION_USERNAME@$STATION_IP" "sudo /tmp/provision.sh"
ssh -A "$EIRINI_STATION_USERNAME@$STATION_IP" "/tmp/provision-user.sh"

if [[ -f "$STATION_HISTORY_BACKUP" ]]; then
  scp -r "$STATION_HISTORY_BACKUP" "$EIRINI_STATION_USERNAME@$STATION_IP:~/.zsh_history"
fi
