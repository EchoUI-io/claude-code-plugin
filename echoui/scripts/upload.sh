#!/usr/bin/env bash
set -euo pipefail

# Upload a text file to Echo UI
# Usage: upload.sh <local_file> <remote_path>

LOCAL_FILE="${1:?Usage: upload.sh <local_file> <remote_path>}"
REMOTE_PATH="${2:?Usage: upload.sh <local_file> <remote_path>}"
ECHOUI_API_URL="${ECHOUI_API_URL:-https://echoui.app}"

if [ -z "${ECHOUI_API_KEY:-}" ]; then
    echo "Error: ECHOUI_API_KEY environment variable is not set" >&2
    exit 1
fi

CONTENT=$(cat "$LOCAL_FILE")

curl -s -X POST "${ECHOUI_API_URL}/api/v1/files" \
    -H "Authorization: Bearer ${ECHOUI_API_KEY}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "$(jq -n --arg content "$CONTENT" --arg path "$REMOTE_PATH" '{content: $content, remote_path: $path}')"
