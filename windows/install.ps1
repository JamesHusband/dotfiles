# Entry point: Full system bootstrap for Windows
#Requires -Version 5.1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Starting Windows system bootstrap..."

# Run phases in order
& "$ScriptDir\post-install\update.ps1"
& "$ScriptDir\post-install\post-install.ps1"
& "$ScriptDir\packages\install-packages.ps1"
& "$ScriptDir\services\enable-services.ps1"
& "$ScriptDir\config\config.ps1"
& "$ScriptDir\ricing\rice.ps1"

Write-Host "Windows system bootstrap complete."

