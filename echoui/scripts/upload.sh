#!/usr/bin/env bash
set -euo pipefail

# Upload a text file to Echo UI
# Usage: upload.sh <local_file> <remote_path>
#
# Prints the API's JSON response on stdout and exits non-zero on any HTTP
# status outside 2xx, so a caller can branch on the exit code instead of
# parsing the body.

LOCAL_FILE="${1:?Usage: upload.sh <local_file> <remote_path>}"
REMOTE_PATH="${2:?Usage: upload.sh <local_file> <remote_path>}"
ECHOUI_API_URL="${ECHOUI_API_URL:-https://echoui.app}"

if [ -z "${ECHOUI_API_KEY:-}" ]; then
    echo "Error: ECHOUI_API_KEY environment variable is not set" >&2
    exit 1
fi

if [ ! -r "$LOCAL_FILE" ]; then
    echo "Error: cannot read '${LOCAL_FILE}'" >&2
    exit 1
fi

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

# `--rawfile` reads the document straight off disk, so nothing about the file's
# size reaches the argument list. The previous
# `--arg content "$(cat "$LOCAL_FILE")"` made the whole file one argv entry, and
# a large enough page died with "jq: Argument list too long" -- then, because
# the status went unchecked, posted an empty body and reported the API's 422 as
# a success.
jq -n --rawfile content "$LOCAL_FILE" --arg path "$REMOTE_PATH" \
    '{content: $content, remote_path: $path}' \
    > "${WORK}/body.json"

STATUS="$(curl -sS -o "${WORK}/response.json" -w '%{http_code}' \
    -X POST "${ECHOUI_API_URL}/api/v1/files" \
    -H "Authorization: Bearer ${ECHOUI_API_KEY}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    --data-binary "@${WORK}/body.json")"

cat "${WORK}/response.json"

if [ "${STATUS}" -lt 200 ] || [ "${STATUS}" -ge 300 ]; then
    echo >&2
    echo "Error: Echo UI returned HTTP ${STATUS} uploading '${REMOTE_PATH}'" >&2
    exit 1
fi
