# Echo UI Claude Code Plugin Installer for Windows
# Usage: iwr -useb https://raw.githubusercontent.com/echoui/claude-code/master/install.ps1 | iex

$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/EchoUI-io/claude-code-plugin"
$EchoUiApiUrl = if ($env:ECHOUI_API_URL) { $env:ECHOUI_API_URL } else { "https://echoui.app" }

Write-Host "=== Echo UI Plugin Installer ===" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
foreach ($cmd in @("claude", "curl")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "'$cmd' is required but not installed."
        exit 1
    }
}

# Auto-install jq if missing
if (-not (Get-Command "jq" -ErrorAction SilentlyContinue)) {
    Write-Host "'jq' is not installed. Attempting to install..." -ForegroundColor Yellow
    $installed = $false

    # Try winget first
    if (Get-Command "winget" -ErrorAction SilentlyContinue) {
        Write-Host "Installing jq via winget..."
        winget install --id jqlang.jq --accept-source-agreements --accept-package-agreements -e
        # Refresh PATH so jq is found in this session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        if (Get-Command "jq" -ErrorAction SilentlyContinue) { $installed = $true }
    }

    # Try choco
    if (-not $installed -and (Get-Command "choco" -ErrorAction SilentlyContinue)) {
        Write-Host "Installing jq via Chocolatey..."
        choco install jq -y
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        if (Get-Command "jq" -ErrorAction SilentlyContinue) { $installed = $true }
    }

    # Try scoop
    if (-not $installed -and (Get-Command "scoop" -ErrorAction SilentlyContinue)) {
        Write-Host "Installing jq via Scoop..."
        scoop install jq
        if (Get-Command "jq" -ErrorAction SilentlyContinue) { $installed = $true }
    }

    if (-not $installed) {
        Write-Error "Could not install 'jq' automatically. Please install it manually: https://jqlang.github.io/jq/download/"
        exit 1
    }
    Write-Host "jq installed successfully." -ForegroundColor Green
}

# Prompt for API key
if (-not $env:ECHOUI_API_KEY) {
    $env:ECHOUI_API_KEY = Read-Host "Enter your Echo UI API key (starts with echo_live_)"
}

if (-not $env:ECHOUI_API_KEY.StartsWith("echo_live_")) {
    Write-Error "API key must start with 'echo_live_'"
    exit 1
}

# Validate key
Write-Host "Validating API key..."
$response = curl -s -o NUL -w "%{http_code}" "$EchoUiApiUrl/api/v1/files" -H "Authorization: Bearer $($env:ECHOUI_API_KEY)" -H "Accept: application/json"

if ($response -ne "200") {
    Write-Error "API key validation failed (HTTP $response)"
    exit 1
}
Write-Host "API key valid." -ForegroundColor Green

# Add to PowerShell profile
$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) {
    New-Item -Path $profilePath -Force | Out-Null
}

$profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
if (-not $profileContent -or -not $profileContent.Contains("ECHOUI_API_KEY")) {
    Add-Content $profilePath "`n# Echo UI API Key`n`$env:ECHOUI_API_KEY = `"$($env:ECHOUI_API_KEY)`""
    Write-Host "Added ECHOUI_API_KEY to $profilePath"
}

# Install plugin
Write-Host "Installing Echo UI plugin..."
claude plugin marketplace add $RepoUrl
claude plugin install echoui

Write-Host ""
Write-Host "=== Installation complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Available skills:"
Write-Host "  /echoui:publish  - Publish files to live URLs"
Write-Host "  /echoui:list     - List published files"
Write-Host "  /echoui:delete   - Delete a file"
Write-Host "  /echoui:preview  - Open a file in the browser"
Write-Host ""
Write-Host "Restart your shell or run: . `$PROFILE"
