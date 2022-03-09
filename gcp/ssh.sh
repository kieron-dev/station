#!/bin/bash
set -euo pipefail

ip=$(
  gcloud compute instances describe "${EIRINI_STATION_USERNAME}-eirini-station" \
    --zone="europe-west2-a" \
    --project="cff-eirini-peace-pods" \
  | grep natIP | cut -d ":" -f 2 | xargs
)

ssh \
  -A \
  -R "/home/${EIRINI_STATION_USERNAME}/.gnupg/S.gpg-agent-host:$(gpgconf --list-dirs agent-socket)" \
  "${EIRINI_STATION_USERNAME}@$ip"
