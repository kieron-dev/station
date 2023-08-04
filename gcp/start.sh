#!/bin/bash
set -euo pipefail

gcloud compute instances start "${EIRINI_STATION_USERNAME}-eirini-station" \
  --zone="europe-west2-a" \
  --project="tap-sandbox-dev"
