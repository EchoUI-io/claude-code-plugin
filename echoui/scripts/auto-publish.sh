#!/usr/bin/env bash
set -euo pipefail

# Auto-publish hook script — called by Claude Code Stop hook.
# Finds the most recently written HTML file in echoui-output/output-style-response/
# and uploads it to Echo UI via upload.sh.

OUTPUT_DIR="echoui-output/output-style-response"

# No-op if the output directory doesn't exist (output style not active)
if [ ! -d "$OUTPUT_DIR" ]; then
    exit 0
fi

# Find the most recently modified .html file
NEWEST=$(find "$OUTPUT_DIR" -name '*.html' -type f -printf '%T@\t%p\n' 2>/dev/null | sort -rn | head -1 | cut -f2-)

# No-op if no HTML files found
if [ -z "${NEWEST:-}" ]; then
    exit 0
fi

# Derive remote path: echoui-output/output-style-response/a3f9/20260302-153045.html -> responses/a3f9/20260302-153045.html
RELATIVE="${NEWEST#echoui-output/output-style-response/}"
REMOTE_PATH="responses/${RELATIVE}"

# Resolve upload.sh path (same directory as this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Upload — suppress errors so the hook never blocks Claude Code
bash "${SCRIPT_DIR}/upload.sh" "$NEWEST" "$REMOTE_PATH" 2>/dev/null || true
