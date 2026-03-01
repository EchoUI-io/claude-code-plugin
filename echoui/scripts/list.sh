#!/usr/bin/env bash
set -euo pipefail

# List published files on Echo UI
# Usage: list.sh [prefix]

ECHOUI_API_URL="${ECHOUI_API_URL:-https://echoui.io}"
PREFIX="${1:-}"

if [ -z "${ECHOUI_API_KEY:-}" ]; then
    echo "Error: ECHOUI_API_KEY environment variable is not set" >&2
    exit 1
fi

URL="${ECHOUI_API_URL}/api/v1/files"
if [ -n "$PREFIX" ]; then
    URL="${URL}?prefix=$(printf '%s' "$PREFIX" | jq -sRr @uri)"
fi

curl -s "$URL" \
    -H "Authorization: Bearer ${ECHOUI_API_KEY}" \
    -H "Accept: application/json"
