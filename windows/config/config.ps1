# Config phase: Config orchestration
$ErrorActionPreference = "Stop"

Write-Host "Applying configuration..."

# Apply shared configs first
# Then apply OS-specific overrides

Write-Host "Configuration applied."

