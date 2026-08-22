---
name: publish
description: Use when the user wants to publish, upload, or deploy HTML, CSS, JS, SVG, or image files to a live URL on Echo UI.
allowed-tools: Bash(bash:*, curl:*, base64:*)
---

# Echo UI Publish

## Overview

Uploads a file to Echo UI via the REST API and returns its live URL. The file
may be one you author for this purpose, or one that already exists on disk — a
screenshot, an exported chart, a PDF-adjacent asset.

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

1. **Locate or write the file.**
   - Authoring something new: write it to `echoui-output/<remote_path>` with the Write tool.
   - Publishing a file that already exists: use it where it is. Do not copy it into `echoui-output/` first.
2. **Upload** with the script matching the extension (replace the path with the resolved absolute path):

```bash
# Text files
bash "<resolved_scripts_dir>/upload.sh" "<local_file>" "<remote_path>"

# Binary files
bash "<resolved_scripts_dir>/upload_binary.sh" "<local_file>" "<remote_path>"
```

3. **Check the exit code.** Both scripts exit non-zero on any non-2xx response
   and print the reason to stderr. A zero exit with a JSON body carrying `url`,
   `path` and `size` is a successful upload.
4. **Verify before reporting**, whenever the URL will be embedded somewhere a
   broken image is expensive — a PR body, a report, a message to someone else:

```bash
curl -s -o /dev/null -w '%{http_code} %{content_type} %{size_download}\n' "<url>"
```

   Expect `200`, the right content type, and a byte count matching the local
   file. A URL that has never been fetched is not yet evidence of anything.
5. **Report the live URL** to the user.

## Notes

- **There is no practical size ceiling.** Both scripts stream the payload
  through a temp file, so a multi-megabyte screenshot or a large generated page
  uploads the same way a small one does. (Before v1.1 they passed the content as
  a `jq` argument, which failed above roughly 90KB of source file with
  `jq: Argument list too long` — and, because the status went unchecked, showed
  up as a 422 about missing content rather than as an error.)
- **Re-publishing the same `remote_path` overwrites it** and keeps the URL, which
  is what you want for an asset someone has already linked.

## Error Handling

- **401**: API key invalid or expired. Tell the user to regenerate it.
- **422**: Validation error (unsupported extension, invalid path). Read the
  message in the response body — it names the field.
- **`ECHOUI_API_KEY` not set**: the script says so and exits 1. Tell the user to
  export it (`export ECHOUI_API_KEY=echo_live_...`).
- **curl failure**: check network. Default API URL is `https://echoui.app`
  (override with `ECHOUI_API_URL`).
