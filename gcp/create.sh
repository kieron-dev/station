#!/bin/bash
set -euo pipefail

gcloud compute resource-policies create instance-schedule "$EIRINI_STATION_USERNAME-shutdown-schedule" \
  --description="shut down the machine every day at 19:00 UTC" \
  --project="tap-sandbox-dev" \
  --region="europe-west2" \
  --vm-stop-schedule="0 19 * * *"
gcloud compute instances create "$EIRINI_STATION_USERNAME-eirini-station" \
  --project="tap-sandbox-dev" \
  --metadata=ssh-keys="$EIRINI_STATION_USERNAME:$(ssh-add -L)" \
  --image-project="ubuntu-os-cloud" \
  --image-family="ubuntu-2204-lts" \
  --machine-type="e2-custom-8-16384" \
  --boot-disk-size="100GB" \
  --boot-disk-type="pd-ssd" \
  --zone="europe-west2-a" \
  --resource-policies="$EIRINI_STATION_USERNAME-shutdown-schedule"
