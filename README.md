# Echo UI Plugin for Claude Code

Publish HTML pages, images, and static files to live URLs directly from Claude Code.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/EchoUI-io/claude-code-plugin/refs/heads/master/install.sh | bash
```

**Windows:**
```powershell
iwr -useb https://raw.githubusercontent.com/EchoUI-io/claude-code-plugin/refs/heads/master/install.ps1 | iex
```

## Prerequisites

- [Claude Code](https://claude.ai/code) CLI installed
- An [Echo UI](https://echoui.app) account with an API key
- `curl` and `jq` installed

## Manual Install

1. Get your API key from [echoui.app/settings/api-key](https://echoui.app/settings/api-key)
2. Add to your shell profile:
   ```bash
   export ECHOUI_API_KEY="echo_live_your_key_here"
   ```
3. Install the plugin:
   ```bash
   claude plugin add-marketplace https://github.com/EchoUI-io/claude-code-plugin
   claude plugin install echoui
   ```

## Skills

| Skill | Description |
|-------|-------------|
| `/echoui:publish` | Write and publish files to live URLs |
| `/echoui:list` | List all published files |
| `/echoui:delete` | Delete a published file |
| `/echoui:preview` | Open a published file in the browser |

## Examples

```
> /echoui:publish
> Create a landing page for my project and publish it

> /echoui:list
> Show me all my published files

> /echoui:delete
> Remove the old report.html file
```

## Environment Variables

| Variable | Required | Default             | Description |
|----------|----------|---------------------|-------------|
| `ECHOUI_API_KEY` | Yes | —                   | Your Echo UI API key (starts with `echo_live_`) |
| `ECHOUI_API_URL` | No | `https://echoui.app` | Custom API URL (for self-hosted instances) |

## License

MIT
