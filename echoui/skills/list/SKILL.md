---
name: list
description: Use when the user wants to see what files are published on Echo UI, check URLs, or verify a deployment.
allowed-tools: Bash(bash:*, curl:*)
---

# Echo UI List Files

## Overview

Lists all published files for the authenticated user, with optional prefix filtering.

## Script Path Resolution

The skill base directory shown above is `<plugin>/skills/list`. The list script is at `<plugin>/scripts/list.sh`.

**Derive the script path** from the base directory by going up two levels and into scripts:
- Base directory: (shown in "Base directory for this skill" above)
- Script path: `<base_directory>/../../scripts/list.sh`

## Steps

1. List files (replace the path with the resolved absolute path):

```bash
# All files
bash "<resolved_script_path>"

# Filtered by prefix
bash "<resolved_script_path>" "reports/"
```

3. Present results in a readable format showing path, URL, size, and last updated time.

## Error Handling

- **401**: API key invalid. Tell the user to regenerate it.
- **Empty array `[]`**: No files published yet. Suggest using `echoui:publish`.
