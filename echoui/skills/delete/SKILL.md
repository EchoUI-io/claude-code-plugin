---
name: delete
description: Use when the user wants to remove or delete a published file from Echo UI.
allowed-tools: Bash(bash:*, curl:*)
---

# Echo UI Delete File

## Overview

Deletes a published file from Echo UI by its remote path. This is destructive and cannot be undone.

## Script Path Resolution

The skill base directory shown above is `<plugin>/skills/delete`. The delete script is at `<plugin>/scripts/delete.sh`.

**Derive the script path** from the base directory by going up two levels and into scripts:
- Base directory: (shown in "Base directory for this skill" above)
- Script path: `<base_directory>/../../scripts/delete.sh`

## Steps

1. **Confirm with the user** which file to delete. If unsure, use `echoui:list` first.
2. Delete the file (replace the path with the resolved absolute path):

```bash
bash "<resolved_script_path>" "<remote_path>"
```

4. Check the response — `"deleted": true` means success.

## Error Handling

- **404**: File doesn't exist. Use `echoui:list` to show what's available.
- **401**: API key invalid. Tell the user to regenerate it.
