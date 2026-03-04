# Echo UI Claude Code Plugin

A Claude Code plugin that publishes HTML, CSS, JS, SVG, and image files to live Echo UI URLs via the REST API.

## Repository Structure

```
echoui/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (name, version, skills list)
├── hooks/
│   └── hooks.json           # Stop hook for auto-publish
├── output-styles/
│   └── echoui-html.md       # HTML output style with auto-publish
├── skills/
│   ├── publish/SKILL.md     # Upload text & binary files to live URLs
│   ├── list/SKILL.md        # List published files
│   ├── delete/SKILL.md      # Delete a published file
│   └── preview/SKILL.md     # Open a published page in the browser
└── scripts/
    ├── upload.sh             # Text file upload (HTML, CSS, JS, SVG)
    ├── upload_binary.sh      # Binary file upload via base64 (PNG, JPG, GIF, WebP, ICO)
    ├── auto-publish.sh       # Stop hook script for output style auto-publish
    ├── list.sh               # GET /api/v1/files (optional prefix filter)
    └── delete.sh             # DELETE /api/v1/files/{path}
.claude-plugin/
└── marketplace.json          # Marketplace registry entry
install.sh                    # Bash/Zsh installer (Linux/macOS)
install.ps1                   # PowerShell installer (Windows)
```

## Architecture

Skills (SKILL.md) define the workflow and error handling for each operation. They delegate to shell scripts in `scripts/` which wrap `curl` calls to the Echo UI REST API.

**API endpoints** (base: `https://echoui.app` or `ECHOUI_API_URL`):
- `POST /api/v1/files` — Upload a file (text as JSON content, binary as base64)
- `GET /api/v1/files` — List files (optional `?prefix=` filter)
- `DELETE /api/v1/files/{path}` — Delete a file

**Auth**: Bearer token via `ECHOUI_API_KEY` environment variable.

## Prerequisites

- `ECHOUI_API_KEY` env var must be set (starts with `echo_live_`). If missing, tell the user to get one from their Echo UI dashboard at Settings > API Key, then `export ECHOUI_API_KEY=echo_live_...`
- `curl` and `jq` must be installed
- Optional: `ECHOUI_API_URL` overrides the default `https://echoui.app`

## Resolving Script Paths

Skills reference helper scripts in `scripts/`. When a skill is invoked, its base directory is shown at the top. Derive the scripts path:

```
Script dir = <skill_base_directory>/../../scripts/
```

For example, if the skill base directory is `/home/user/.claude/plugins/cache/echoui/echoui/1.0.0/skills/publish`, then scripts are at `/home/user/.claude/plugins/cache/echoui/echoui/1.0.0/scripts/`.

## Supported File Types

| Type | Extensions | Upload method |
|------|-----------|---------------|
| Text | .html, .css, .js, .svg | `upload.sh` (raw content in JSON) |
| Binary | .png, .jpg, .jpeg, .gif, .webp, .ico | `upload_binary.sh` (base64-encoded) |

## Skills

- `echoui:publish` — Write and upload files to live URLs
- `echoui:list` — List published files
- `echoui:delete` — Delete a published file (destructive, cannot be undone)
- `echoui:preview` — Open a page in the browser

## Output Styles

- `Echo UI HTML` — Formats all Claude Code responses as polished HTML pages, auto-published to Echo UI via Stop hook

### How It Works

1. User activates via `/output-style` → "Echo UI HTML"
2. Claude formats every response as a complete HTML page with embedded CSS
3. Claude writes each page to `echoui-output/output-style-response/{session-id}/{timestamp}.html`
4. The Stop hook (`auto-publish.sh`) detects the new file and uploads it via `upload.sh`
5. Remote path: `responses/{session-id}/{timestamp}.html`

## Hooks

- `hooks/hooks.json` — Registers the Stop hook (auto-discovered by Claude Code)
- `scripts/auto-publish.sh` — Finds newest HTML file in `echoui-output/output-style-response/` and uploads it

## Development Notes

- The plugin manifest is at `echoui/.claude-plugin/plugin.json` (version 1.0.0)
- `upload_binary.sh` handles cross-platform base64 encoding (macOS `base64` vs Linux `base64 -w0`)
- Installers validate the API key format and test connectivity before completing setup
- No test suite exists — scripts can be tested manually against the live API
