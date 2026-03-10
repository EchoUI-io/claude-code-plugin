---
name: preview
description: Use when the user wants to open, view, or preview a published Echo UI page in the browser.
allowed-tools: Bash(bash:*, open:*, xdg-open:*, start:*), AskUserQuestion
---

# Echo UI Preview

## Overview

Lists all published Echo UI pages, lets the user pick one, and opens it in the default browser.

## Script Path Resolution

The skill base directory shown above is `<plugin>/skills/preview`. The list script is at `<plugin>/scripts/list.sh`.

**Derive the script path** from the base directory by going up two levels and into scripts:
- Base directory: (shown in "Base directory for this skill" above)
- Script path: `<base_directory>/../../scripts/list.sh`

## Steps

1. **Fetch published files** by running `list.sh` (resolve the script path as above):

```bash
bash "<resolved_script_path>"
```

2. **Handle empty result**: If the response is an empty array `[]`, tell the user they have no published files and suggest using `echoui:publish` to upload one. Stop here.

3. **Present a numbered list** of available pages. For each file, show the number, file path, and full URL. Example format:

```
Published pages:

  1. index.html — https://echoui.app/u/abc123/index.html
  2. reports/q4.html — https://echoui.app/u/abc123/reports/q4.html
  3. demo/app.html — https://echoui.app/u/abc123/demo/app.html
```

4. **Ask the user to select** a page by number using `AskUserQuestion`. Prompt example: "Enter the number of the page to open (1-N):"

5. **Open the selected URL** in the default browser:

```bash
if command -v open >/dev/null 2>&1; then
    open "<selected_url>"
elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "<selected_url>"
elif command -v start >/dev/null 2>&1; then
    start "<selected_url>"
else
    echo "Could not detect browser opener. Visit: <selected_url>"
fi
```

6. **Confirm** to the user which page was opened and show the URL.

## Error Handling

- **401**: API key invalid. Tell the user to regenerate it at Settings > API Key.
- **ECHOUI_API_KEY not set**: Tell the user to export it (`export ECHOUI_API_KEY=echo_live_...`).
- **Invalid selection**: If the user enters a number outside the valid range, ask again.
