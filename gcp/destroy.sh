#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo "Backing up history file into: '$STATION_HISTORY_BACKUP'"
scp -r "$EIRINI_STATION_USERNAME@$STATION_IP:~/.zsh_history" "$STATION_HISTORY_BACKUP" || true

gcloud compute instances delete "$EIRINI_STATION_USERNAME-eirini-station" \
  --project="tap-sandbox-dev" \
  --zone="europe-west2-a"
gcloud compute resource-policies delete "$EIRINI_STATION_USERNAME-shutdown-schedule" \
  --project="tap-sandbox-dev" \
  --region="europe-west2"
