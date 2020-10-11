#!/bin/bash

set -Eeuo pipefail

err() {
    echo "Error occurred:"
    awk 'NR>L-4 && NR<L+4 { printf "%-5d%3s%s\n",NR,(NR==L?">>>":""),$0 }' L=$1 $0
}
trap 'err $LINENO' ERR

echo "inotify settings"
echo "================"
echo
echo "  Source:           ${SOURCE}"
echo "  Destination:      ${DESTINATION}"
echo

FDUPES_ARGS=""
# Always delete source instead of destination
# Fdupes sorts by name and keeps the first entry
if [[ "${SOURCE}" > "${DESTINATION}" ]]; then
    FDUPES_ARGS="--reverse"
fi

echo "[Starting inotifywait...]"
last_run=0
inotifywait -e create --recursive --monitor --format '%T' --timefmt '%s' "${SOURCE}" | \
    while read timestamp; do
        if test $timestamp -ge $last_run; then
            sleep 1
            last_run=$(date +%s)
            echo "[Found new file at $(date)]"
            fdupes --recurse --delete --noprompt ${FDUPES_ARGS} ${SOURCE} ${DESTINATION}
            # Fallback to GPSDateTime if DateTimeOriginal is not set
            exiftool '-Directory<GPSDateTime' '-Directory<DateTimeOriginal' -d ${DESTINATION}/%Y -r ${SOURCE} || true
        fi
    done
