#!/usr/bin/env bash
set -euo pipefail

# Upload a binary file to Echo UI (base64-encoded)
# Usage: upload_binary.sh <local_file> <remote_path>

LOCAL_FILE="${1:?Usage: upload_binary.sh <local_file> <remote_path>}"
REMOTE_PATH="${2:?Usage: upload_binary.sh <local_file> <remote_path>}"
ECHOUI_API_URL="${ECHOUI_API_URL:-https://echoui.io}"

if [ -z "${ECHOUI_API_KEY:-}" ]; then
    echo "Error: ECHOUI_API_KEY environment variable is not set" >&2
    exit 1
fi

CONTENT=$(base64 -w0 "$LOCAL_FILE" 2>/dev/null || base64 "$LOCAL_FILE")

curl -s -X POST "${ECHOUI_API_URL}/api/v1/files" \
    -H "Authorization: Bearer ${ECHOUI_API_KEY}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "$(jq -n --arg content "$CONTENT" --arg path "$REMOTE_PATH" '{content: $content, remote_path: $path, encoding: "base64"}')"
