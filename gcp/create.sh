#!/bin/bash
set -euo pipefail

# not working on my machine with Google Cloud SDK 375.0.0:
# ERROR: gcloud crashed (InvalidHeader): Invalid return character or leading space in header: b'authorization'

# gcloud compute instances create "$EIRINI_STATION_USERNAME-eirini-station" \
#   --project="cff-eirini-peace-pods" \
#   --image-family="ubuntu-2004-lts" \
#   --machine-type="n1-standard-8" \
#   --boot-disk-size="100GB" \
#   --boot-disk-type="pd-ssh" \
#   --zone="europe-west2-a"

terraform init
terraform apply -var="username=$EIRINI_STATION_USERNAME"
