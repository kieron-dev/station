#!/bin/bash
set -euo pipefail

public_ip=$(gcloud compute instances describe --project cff-eirini-peace-pods --zone="europe-west2-a" georgethebeatle-eirini-station | yq '.networkInterfaces[0].accessConfigs[0].natIP')

echo "Provisioning $EIRINI_STATION_USERNAME-eirini-station"
scp -r ~/workspace/eirini-station/provision*.sh "$EIRINI_STATION_USERNAME@$public_ip:/tmp"
ssh -A -R $HOME/.gnupg/S.gpg-agent-guest:$(gpgconf --list-dirs agent-socket) "$EIRINI_STATION_USERNAME@$public_ip" "sudo /tmp/provision.sh"
ssh -A -R $HOME/.gnupg/S.gpg-agent-guest:$(gpgconf --list-dirs agent-socket) "$EIRINI_STATION_USERNAME@$public_ip" "/tmp/provision-user.sh"
