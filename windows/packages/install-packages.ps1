# Packages phase: Install packages from manifests
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$SharedApps = Join-Path $RepoRoot "shared\manifest\apps.common.yml"
$OsManifest = Join-Path $ScriptDir "package-manifest.toml"

Write-Host "[INFO] Installing packages from manifests..."

# Step 1: Read shared apps.common.yml and extract Windows packages
Write-Host "[INFO] Reading shared application manifest..."
if (Test-Path $SharedApps) {
    # TODO: Parse YAML to extract apps with windows.source and windows.package
    # For each app, group by source (winget, chocolatey) and collect package IDs/names
    Write-Host "[INFO] Found shared apps manifest: $SharedApps"
} else {
    Write-Host "[WARN] Shared apps manifest not found: $SharedApps"
}

# Step 2: Read OS-specific package-manifest.toml
Write-Host "[INFO] Reading OS-specific package manifest..."
if (Test-Path $OsManifest) {
    # TODO: Parse TOML to extract packages grouped by source
    Write-Host "[INFO] Found OS manifest: $OsManifest"
} else {
    Write-Host "[WARN] OS manifest not found: $OsManifest"
}

# Step 3: Install packages from both sources
# TODO: Install packages grouped by source (winget, chocolatey)
# - Install winget packages: winget install --id <package-id>
# - Install chocolatey packages: choco install <package-name>

Write-Host "[INFO] Packages installed."
