#!/bin/bash

set -Eeuo pipefail

err() {
    echo "Error occurred:"
    awk 'NR>L-4 && NR<L+4 { printf "%-5d%3s%s\n",NR,(NR==L?">>>":""),$0 }' L=$1 $0
}
trap 'err $LINENO' ERR

INOTIFY_EVENTS_DEFAULT="create,modify,move"
INOTIFY_OPTONS_DEFAULT='--monitor'

echo "inotify settings"
echo "================"
echo
echo "  Source:           ${SOURCE}"
echo "  Destination:      ${DESTINATION}"
echo "  Inotify_Events:   ${INOTIFY_EVENTS:=${INOTIFY_EVENTS_DEFAULT}}"
echo "  Inotify_Options:  ${INOTIFY_OPTONS:=${INOTIFY_OPTONS_DEFAULT}}"
echo

echo "[Starting inotifywait...]"
inotifywait -e ${INOTIFY_EVENTS} ${INOTIFY_OPTONS} "${SOURCE}" | \
    while read -r notifies; do
        echo "notify received"
        echo "$notifies"
        echo exiftool -o . '-Directory<CreateDate' -d ${DESTINATION}/%Y -r ${SOURCE}
    done
