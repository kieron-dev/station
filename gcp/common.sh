info=$(
  gcloud compute instances describe "${EIRINI_STATION_USERNAME}-eirini-station" \
    --project cf-on-k8s-wg \
    --zone="europe-west2-a" \
    --format="value(status, networkInterfaces[0].accessConfigs[0].natIP, name)"
)

export STATION_STATUS=$(cut -f 1 -d ' ' <<<$info)
export STATION_IP=$(cut -f 2 -d ' ' <<<$info)
export STATION_NAME=$(cut -f 3 -d ' ' <<<$info)
export STATION_HISTORY_BACKUP="$HOME/eirini-station-history-backup"
