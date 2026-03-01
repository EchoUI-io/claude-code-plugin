---
name: publish
description: Use when the user wants to publish, upload, or deploy HTML, CSS, JS, SVG, or image files to a live URL on Echo UI.
allowed-tools: Bash(bash:*, curl:*, base64:*)
---

# Echo UI Publish

## Overview

Writes a file locally, then uploads it to Echo UI via the REST API.

## Quick Reference

| Extension | Type | Script |
|-----------|------|--------|
| `.html`, `.css`, `.js`, `.svg` | Text | `scripts/upload.sh` |
| `.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, `.ico` | Binary | `scripts/upload_binary.sh` |

## Script Path Resolution

The skill base directory shown above is `<plugin>/skills/publish`. The upload scripts are at `<plugin>/scripts/`.

**Derive the script path** from the base directory by going up two levels and into scripts:
- Base directory: (shown in "Base directory for this skill" above)
- Upload script: `<base_directory>/../../scripts/upload.sh`
- Binary upload script: `<base_directory>/../../scripts/upload_binary.sh`

## Steps

1. Write the file content to `echoui-output/<remote_path>` using the Write tool
2. Upload using the appropriate script based on the table above (replace the path with the resolved absolute path):

```bash
# Text files
bash "<resolved_scripts_dir>/upload.sh" "echoui-output/<remote_path>" "<remote_path>"

# Binary files
bash "<resolved_scripts_dir>/upload_binary.sh" "echoui-output/<remote_path>" "<remote_path>"
```

4. Parse the JSON response — it returns `url`, `path`, and `size`
5. Report the live URL to the user

## Error Handling

- **401**: API key invalid or expired. Tell user to regenerate it.
- **422**: Validation error (unsupported extension, invalid path). Check the error message.
- **curl failure**: Check network. Default API URL is `https://echoui.io` (override with `ECHOUI_API_URL`).
