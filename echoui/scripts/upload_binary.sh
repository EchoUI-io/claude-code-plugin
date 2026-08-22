#!/usr/bin/env bash
set -euo pipefail

# Upload a binary file to Echo UI (base64-encoded)
# Usage: upload_binary.sh <local_file> <remote_path>
#
# Prints the API's JSON response on stdout and exits non-zero on any HTTP
# status outside 2xx, so a caller can branch on the exit code instead of
# parsing the body.

LOCAL_FILE="${1:?Usage: upload_binary.sh <local_file> <remote_path>}"
REMOTE_PATH="${2:?Usage: upload_binary.sh <local_file> <remote_path>}"
ECHOUI_API_URL="${ECHOUI_API_URL:-https://echoui.app}"

if [ -z "${ECHOUI_API_KEY:-}" ]; then
    echo "Error: ECHOUI_API_KEY environment variable is not set" >&2
    exit 1
fi

if [ ! -r "$LOCAL_FILE" ]; then
    echo "Error: cannot read '${LOCAL_FILE}'" >&2
    exit 1
fi

# The payload goes through temp files rather than shell variables and jq argv
# entries. Passing base64 as `jq --arg content "$CONTENT"` makes it a single
# argv entry, so anything past ARG_MAX -- around 90KB of source file in
# practice, which an ordinary full-page screenshot clears easily -- died with
# "jq: Argument list too long". The old script did not check the status either,
# so that surfaced as an empty POST body and a 422 from the API rather than as
# an error here.
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

# `-w0` is GNU coreutils; BSD/macOS base64 rejects it and wraps at 76 columns,
# so strip newlines on the fallback rather than trusting the flag.
if ! base64 -w0 "$LOCAL_FILE" > "${WORK}/content" 2>/dev/null; then
    base64 "$LOCAL_FILE" | tr -d '\n' > "${WORK}/content"
fi

jq -n --rawfile content "${WORK}/content" --arg path "$REMOTE_PATH" \
    '{content: ($content | rtrimstr("\n")), remote_path: $path, encoding: "base64"}' \
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
