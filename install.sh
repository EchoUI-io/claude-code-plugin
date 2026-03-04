#!/usr/bin/env bash
set -euo pipefail

# Echo UI Claude Code Plugin Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/echoui/claude-code/master/install.sh | bash

REPO_URL="https://github.com/EchoUI-io/claude-code-plugin"
ECHOUI_API_URL="${ECHOUI_API_URL:-https://echoui.app}"

echo "=== Echo UI Plugin Installer ==="
echo ""

# Check prerequisites
for cmd in claude curl jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' is required but not installed." >&2
        exit 1
    fi
done

# Prompt for API key
if [ -z "${ECHOUI_API_KEY:-}" ]; then
    echo "Enter your Echo UI API key (starts with echo_live_):"
    read -r ECHOUI_API_KEY < /dev/tty
fi

if [[ ! "$ECHOUI_API_KEY" =~ ^echo_live_ ]]; then
    echo "Error: API key must start with 'echo_live_'" >&2
    exit 1
fi

# Validate key
echo "Validating API key..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
    "${ECHOUI_API_URL}/api/v1/files" \
    -H "Authorization: Bearer ${ECHOUI_API_KEY}" \
    -H "Accept: application/json")

if [ "$HTTP_STATUS" != "200" ]; then
    echo "Error: API key validation failed (HTTP $HTTP_STATUS)" >&2
    exit 1
fi
echo "API key valid."

# Add to shell profile
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
    if ! grep -q "ECHOUI_API_KEY" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# Echo UI API Key" >> "$SHELL_RC"
        echo "export ECHOUI_API_KEY=\"${ECHOUI_API_KEY}\"" >> "$SHELL_RC"
        echo "Added ECHOUI_API_KEY to $SHELL_RC"
    else
        echo "ECHOUI_API_KEY already exists in $SHELL_RC"
    fi
fi

# Install plugin
echo "Installing Echo UI plugin..."
claude plugin marketplace add "$REPO_URL"
claude plugin install echoui

echo ""
echo "=== Installation complete! ==="
echo ""
echo "Available skills:"
echo "  /echoui:publish  - Publish files to live URLs"
echo "  /echoui:list     - List published files"
echo "  /echoui:delete   - Delete a file"
echo "  /echoui:preview  - Open a file in the browser"
echo ""
echo "Restart your shell or run: source $SHELL_RC"
