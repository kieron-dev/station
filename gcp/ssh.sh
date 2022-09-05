#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if [[ "$STATION_STATUS" != "RUNNING" ]]; then
  echo "Station is not runninng. Run 'station start' to start it"
  exit 1
fi

for attempt in $(seq 10); do
  if ssh \
    -A \
    -R "/home/${EIRINI_STATION_USERNAME}/.gnupg/S.gpg-agent-host:$(gpgconf --list-dirs agent-socket)" \
    -o "UserKnownHostsFile=/dev/null" \
    "${EIRINI_STATION_USERNAME}@${STATION_IP}"; then
    exit 0
  fi

  sleep 1
done

echo "Unable to ssh to the station after $attempt attempts"
exit 1
