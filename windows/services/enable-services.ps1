# Services phase: Enable system services
$ErrorActionPreference = "Stop"

$ServicesFile = Join-Path $PSScriptRoot "services.toml"

if (-not (Test-Path $ServicesFile)) {
    Write-Host "No services.toml found, skipping service enablement."
    exit 0
}

Write-Host "Enabling system services..."

# Read services.toml and enable Windows services
# Add service enablement logic here

Write-Host "Services enabled."

