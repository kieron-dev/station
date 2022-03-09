#!/bin/bash
set -euo pipefail

gcloud compute instances delete "$EIRINI_STATION_USERNAME-eirini-station" \
  --project="cff-eirini-peace-pods" \
  --zone="europe-west2-a"
