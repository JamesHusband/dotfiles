# Packages phase: Install packages from manifests
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$SharedApps = Join-Path $RepoRoot "shared\manifest\apps.common.yml"
$OsManifest = Join-Path $ScriptDir "package-manifest.toml"

# Temporary files for package lists
$WingetPackages = Join-Path $env:TEMP "dotphials_winget_packages.txt"
$ChocoPackages = Join-Path $env:TEMP "dotphials_choco_packages.txt"

Write-Host "[INFO] Installing packages from manifests..."

# Check for required Python dependencies
function Check-PythonDeps {
    try {
        python -c "import yaml" 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] PyYAML is not installed."
            Write-Host "[INFO] Installing pyyaml via pip..."
            pip install pyyaml
            if ($LASTEXITCODE -ne 0) {
                Write-Host "[ERROR] Failed to install pyyaml. Please install manually:"
                Write-Host "[ERROR]   pip install pyyaml"
                exit 1
            }
            Write-Host "[INFO] PyYAML installed successfully."
        }
        
        # Check for TOML support
        $hasTomllib = $false
        $hasTomli = $false
        try {
            python -c "import tomllib" 2>$null
            $hasTomllib = ($LASTEXITCODE -eq 0)
        } catch {}
        
        if (-not $hasTomllib) {
            try {
                python -c "import tomli" 2>$null
                $hasTomli = ($LASTEXITCODE -eq 0)
            } catch {}
        }
        
        if (-not $hasTomllib -and -not $hasTomli) {
            Write-Host "[WARN] TOML support not found. Installing tomli..."
            pip install tomli
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[INFO] TOML support installed."
            } else {
                Write-Host "[WARN] Could not install TOML support. TOML parsing may fail."
            }
        }
    } catch {
        Write-Host "[ERROR] Error checking Python dependencies: $_"
        exit 1
    }
}

Check-PythonDeps

# Step 1: Parse shared apps.common.yml and extract Windows packages
Write-Host "[INFO] Reading shared application manifest..."
if (Test-Path $SharedApps) {
    Write-Host "[INFO] Found shared apps manifest: $SharedApps"
    
    # Use Python to parse YAML and extract Windows packages
    $pythonScript = @"
import sys
import os
import yaml

try:
    with open(os.environ['SHARED_APPS_FILE'], 'r') as f:
        data = yaml.safe_load(f)
    
    winget_packages = []
    choco_packages = []
    
    if 'apps' in data:
        for app in data['apps']:
            if 'windows' in app:
                source = app['windows'].get('source', '')
                package = app['windows'].get('package', '')
                if source == 'winget' and package:
                    winget_packages.append(package)
                elif source == 'chocolatey' and package:
                    choco_packages.append(package)
    
    # Write to temporary files
    with open(os.environ['WINGET_FILE'], 'w') as f:
        f.write('\n'.join(winget_packages))
    
    with open(os.environ['CHOCO_FILE'], 'w') as f:
        f.write('\n'.join(choco_packages))
    
except Exception as e:
    print(f"Error parsing YAML: {e}", file=sys.stderr)
    sys.exit(1)
"@
    
    $env:SHARED_APPS_FILE = $SharedApps
    $env:WINGET_FILE = $WingetPackages
    $env:CHOCO_FILE = $ChocoPackages
    $pythonScript | python
    
    if ((Test-Path $WingetPackages) -and (Get-Content $WingetPackages).Length -gt 0) {
        $count = (Get-Content $WingetPackages | Measure-Object -Line).Lines
        Write-Host "[INFO] Found $count winget packages from shared manifest"
    }
    if ((Test-Path $ChocoPackages) -and (Get-Content $ChocoPackages).Length -gt 0) {
        $count = (Get-Content $ChocoPackages | Measure-Object -Line).Lines
        Write-Host "[INFO] Found $count chocolatey packages from shared manifest"
    }
} else {
    Write-Host "[WARN] Shared apps manifest not found: $SharedApps"
    New-Item -ItemType File -Path $WingetPackages -Force | Out-Null
    New-Item -ItemType File -Path $ChocoPackages -Force | Out-Null
}

# Step 2: Parse OS-specific package-manifest.toml
Write-Host "[INFO] Reading OS-specific package manifest..."
if (Test-Path $OsManifest) {
    Write-Host "[INFO] Found OS manifest: $OsManifest"
    
    # Use Python to parse TOML and extract packages
    $pythonScript = @"
import sys
import os

try:
    import tomllib
except ImportError:
    try:
        import tomli as tomllib
    except ImportError:
        print("Error: tomllib (Python 3.11+) or tomli not available.", file=sys.stderr)
        print("Install with: pip install tomli", file=sys.stderr)
        sys.exit(1)

try:
    with open(os.environ['OS_MANIFEST_FILE'], 'rb') as f:
        data = tomllib.load(f)
    
    winget_packages = []
    choco_packages = []
    
    if 'packages' in data:
        if 'winget' in data['packages']:
            winget_packages = data['packages']['winget'].get('packages', [])
        if 'chocolatey' in data['packages']:
            choco_packages = data['packages']['chocolatey'].get('packages', [])
    
    # Append to existing files
    with open(os.environ['WINGET_FILE'], 'a') as f:
        if winget_packages:
            f.write('\n' + '\n'.join(winget_packages) + '\n')
    
    with open(os.environ['CHOCO_FILE'], 'a') as f:
        if choco_packages:
            f.write('\n' + '\n'.join(choco_packages) + '\n')
    
except Exception as e:
    print(f"Error parsing TOML: {e}", file=sys.stderr)
    sys.exit(1)
"@
    
    $env:OS_MANIFEST_FILE = $OsManifest
    $env:WINGET_FILE = $WingetPackages
    $env:CHOCO_FILE = $ChocoPackages
    $pythonScript | python
} else {
    Write-Host "[WARN] OS manifest not found: $OsManifest"
}

# Step 3: Install packages grouped by source
# Install winget packages
if ((Test-Path $WingetPackages) -and (Get-Content $WingetPackages).Length -gt 0) {
    Write-Host "[INFO] Installing winget packages..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $packages = Get-Content $WingetPackages | Where-Object { $_ -ne "" } | Sort-Object -Unique
        foreach ($pkg in $packages) {
            winget install --id $pkg --accept-package-agreements --accept-source-agreements
        }
    } else {
        Write-Host "[WARN] winget not found. Skipping winget packages."
    }
}

# Install chocolatey packages
if ((Test-Path $ChocoPackages) -and (Get-Content $ChocoPackages).Length -gt 0) {
    Write-Host "[INFO] Installing chocolatey packages..."
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        $packages = Get-Content $ChocoPackages | Where-Object { $_ -ne "" } | Sort-Object -Unique
        choco install $packages -y
    } else {
        Write-Host "[WARN] chocolatey not found. Skipping chocolatey packages."
    }
}

# Cleanup
Remove-Item $WingetPackages -ErrorAction SilentlyContinue
Remove-Item $ChocoPackages -ErrorAction SilentlyContinue

Write-Host "[INFO] Packages installed."
