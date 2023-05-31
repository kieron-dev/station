info="$(
  gcloud compute instances describe "${EIRINI_STATION_USERNAME}-eirini-station" \
    --project cf-on-k8s-wg \
    --zone="europe-west2-a" \
    --format="value(status, networkInterfaces[0].accessConfigs[0].natIP, name)"
)"

export STATION_STATUS="$(awk '{print $1}' <<<$info)"
export STATION_IP="$(awk '{print $2}' <<<$info)"
export STATION_NAME="$(awk '{print $3}' <<<$info)"
export STATION_HISTORY_BACKUP="$HOME/eirini-station-history-backup"
