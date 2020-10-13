#!/bin/bash

set -Exeuo pipefail

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
# Destination must be first (smaller)
if [[ "${SOURCE}" < "${DESTINATION}" ]]; then
    FDUPES_ARGS="--reverse"
fi

echo "[Starting inotifywait...]"
inotifywait -e create -e moved_to --recursive --monitor --format '%w%f|%T|%e' --timefmt '%s' --exclude '(tacitpart|_exiftool_tmp)$' "${SOURCE}" | \
    while IFS='|' read path timestamp event; do
        echo "[Found new file at $(date)]"
        echo path: $path timestamp: $timestamp event: $event
        fdupes --recurse --delete --noprompt --order=name ${FDUPES_ARGS} ${SOURCE} ${DESTINATION}

        # Fallback to GPSDateTime if DateTimeOriginal is not set
        # '-keywords<${directory;s#consume_test/##;$_ = undef if /^regex/}'
        # conditions: https://exiftool.org/forum/index.php?topic=3411.0
        # keywords from filename: https://exiftool.org/forum/index.php?topic=8454.0

        # Fallback to GPSDateTime if DateTimeOriginal is not set
        # Set artist if the directory (without source) looks like a name. In my testing "undef" did not overwrite an already existing artist
        exiftool '-Directory<GPSDateTime' '-Directory<DateTimeOriginal' \
            "-artist<\${directory;s#${SOURCE%/}/?##;\$_=undef if not /^[A-Z][a-z]+ [A-Z][a-z]+$/}" \
            -d ${DESTINATION}/%Y -overwrite_original -r "${path}" || true
    done
