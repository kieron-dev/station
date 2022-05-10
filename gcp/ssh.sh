#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if [[ "$STATION_STATUS" != "RUNNING" ]]; then
  echo "Station is not runninng. Run 'station start' to start it"
  exit 1
fi

ssh \
  -A \
  -R "/home/${EIRINI_STATION_USERNAME}/.gnupg/S.gpg-agent-host:$(gpgconf --list-dirs agent-socket)" \
  "${EIRINI_STATION_USERNAME}@$STATION_IP"
