#!/bin/bash
set -euo pipefail

info=$(
  gcloud compute instances describe "${EIRINI_STATION_USERNAME}-eirini-station" \
    --project cff-eirini-peace-pods \
    --zone="europe-west2-a" \
    --format="value(status, networkInterfaces[0].accessConfigs[0].natIP)"
)

status=$(cut -f 1 <<<$info)
ip=$(cut -f 2 <<<$info)

if [[ "$status" != "RUNNING" ]]; then
  echo "Station is not runninng. Run 'station start' to start it"
  exit 1
fi

ssh \
  -A \
  -R "/home/${EIRINI_STATION_USERNAME}/.gnupg/S.gpg-agent-host:$(gpgconf --list-dirs agent-socket)" \
  "${EIRINI_STATION_USERNAME}@$ip"
