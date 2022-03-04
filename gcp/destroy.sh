#!/bin/bash
set -euo pipefail

terraform destroy -var="username=$EIRINI_STATION_USERNAME"
