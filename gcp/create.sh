#!/bin/bash
set -euo pipefail

gcloud compute instances create "$EIRINI_STATION_USERNAME-eirini-station" \
  --project="cff-eirini-peace-pods" \
  --image-project="ubuntu-os-cloud" \
  --image-family="ubuntu-2004-lts" \
  --machine-type="e2-highcpu-8" \
  --boot-disk-size="100GB" \
  --boot-disk-type="pd-ssd" \
  --zone="europe-west2-a"
