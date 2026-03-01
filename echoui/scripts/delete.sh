#!/usr/bin/env bash
set -euo pipefail

# Delete a published file from Echo UI
# Usage: delete.sh <remote_path>

REMOTE_PATH="${1:?Usage: delete.sh <remote_path>}"
ECHOUI_API_URL="${ECHOUI_API_URL:-https://echoui.io}"

if [ -z "${ECHOUI_API_KEY:-}" ]; then
    echo "Error: ECHOUI_API_KEY environment variable is not set" >&2
    exit 1
fi

curl -s -X DELETE "${ECHOUI_API_URL}/api/v1/files/${REMOTE_PATH}" \
    -H "Authorization: Bearer ${ECHOUI_API_KEY}" \
    -H "Accept: application/json"
