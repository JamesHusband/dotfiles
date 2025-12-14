# Config phase: Config orchestration
$ErrorActionPreference = "Stop"

# Get script and repo directories
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$SharedConfig = Join-Path $RepoRoot "shared\config"

Write-Host "Applying configuration..."

# Apply shared configs first
# Alacritty (Windows: %APPDATA%\alacritty\alacritty.toml)
$AlacrittyConfig = "$env:APPDATA\alacritty\alacritty.toml"
$AlacrittySrc = Join-Path $SharedConfig "terminal\alacritty\alacritty.toml"
if (Test-Path $AlacrittySrc) {
    Write-Host "Applying Alacritty configuration..."
    
    # Create directory if needed
    $AlacrittyDir = Split-Path $AlacrittyConfig
    if (-not (Test-Path $AlacrittyDir)) {
        New-Item -ItemType Directory -Force -Path $AlacrittyDir | Out-Null
    }
    
    # Backup existing config if it exists and is not a symlink
    if (Test-Path $AlacrittyConfig) {
        $Item = Get-Item $AlacrittyConfig
        if ($Item.LinkType -eq $null) {
            $BackupPath = "$AlacrittyConfig.bak.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            Write-Host "Backing up existing: $AlacrittyConfig"
            Move-Item $AlacrittyConfig $BackupPath
        } else {
            Remove-Item $AlacrittyConfig -Force
        }
    }
    
    # Create symlink
    New-Item -ItemType SymbolicLink -Path $AlacrittyConfig -Target $AlacrittySrc -Force | Out-Null
    Write-Host "Linked $AlacrittyConfig -> $AlacrittySrc"
}

# Apply OS-specific overrides

Write-Host "Configuration applied."

