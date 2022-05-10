#!/bin/bash
set -euo pipefail

ip=$(gcloud compute instances describe "${EIRINI_STATION_USERNAME}-eirini-station" \
  --project cff-eirini-peace-pods \
  --zone="europe-west2-a" \
  --format="value(networkInterfaces[0].accessConfigs[0].natIP)")

echo "Provisioning $EIRINI_STATION_USERNAME-eirini-station"
scp -r ~/workspace/eirini-station/provision*.sh "$EIRINI_STATION_USERNAME@$ip:/tmp"
ssh -A -R $HOME/.gnupg/S.gpg-agent-guest:$(gpgconf --list-dirs agent-socket) "$EIRINI_STATION_USERNAME@$public_ip" "sudo /tmp/provision.sh"
ssh -A -R $HOME/.gnupg/S.gpg-agent-guest:$(gpgconf --list-dirs agent-socket) "$EIRINI_STATION_USERNAME@$public_ip" "/tmp/provision-user.sh"
