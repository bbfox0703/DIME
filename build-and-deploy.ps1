# ==============================================================================
# DIME - Full Build and Deploy Script
# ==============================================================================
# Compiles all platforms (x64, Win32, ARM64EC) and runs deploy-wix-installer.ps1
# to produce MSI/EXE installers.
#
# Usage:
#   .\build-and-deploy.ps1                  # Interactive mode
#   .\build-and-deploy.ps1 -NonInteractive  # CI/scripted mode (no pauses)
#   .\build-and-deploy.ps1 -SkipBuild       # Skip compilation, only run deploy
# ==============================================================================
param(
    [switch] $NonInteractive,
    [switch] $SkipBuild,
    [switch] $SkipChecksumUpdate
)

$ErrorActionPreference = "Stop"
$startTime = Get-Date

Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host "DIME Full Build and Deploy" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host ""

$repoRoot = (Resolve-Path "$PSScriptRoot").Path
$srcDir   = "$repoRoot\src"
$slnFile  = "$srcDir\DIME.sln"

# ==============================================================================
# Step 0: Locate MSBuild
# ==============================================================================
$vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$msbuildExe = $null
if (Test-Path $vsWhere) {
    $msbuildExe = & $vsWhere -latest -requires Microsoft.Component.MSBuild `
        -find "MSBuild\**\Bin\MSBuild.exe" | Select-Object -First 1
}
if (-not $msbuildExe -or -not (Test-Path $msbuildExe)) {
    $msbuildCmd = Get-Command msbuild -ErrorAction SilentlyContinue
    $msbuildExe = if ($msbuildCmd) { $msbuildCmd.Source } else { $null }
}
if (-not $msbuildExe -or -not (Test-Path $msbuildExe)) {
    Write-Host "ERROR: MSBuild.exe not found. Install Visual Studio or Build Tools." -ForegroundColor Red
    if (-not $NonInteractive) { Read-Host "Press Enter to exit" }
    exit 1
}
Write-Host "MSBuild: $msbuildExe" -ForegroundColor Gray
Write-Host ""

if (-not $SkipBuild) {

    # ==============================================================================
    # Step 1: Generate BuildInfo.h
    # ==============================================================================
    Write-Host "Generating BuildInfo.h..." -ForegroundColor Yellow
    Push-Location $srcDir
    try {
        & cmd.exe /c "call buildInfo.cmd"
        if (-not (Test-Path "$srcDir\BuildInfo.h")) {
            Write-Host "ERROR: BuildInfo.h was not generated!" -ForegroundColor Red
            if (-not $NonInteractive) { Read-Host "Press Enter to exit" }
            exit 1
        }
        Write-Host "  BuildInfo.h generated." -ForegroundColor Green
    } finally {
        Pop-Location
    }
    Write-Host ""

    # ==============================================================================
    # Step 2: Compile all platforms
    # ==============================================================================
    # Build order: Win32 first (DIMESettings only builds for Win32), then x64, then ARM64EC.
    # DIMETests is excluded for ARM64EC to avoid missing atls.lib for ARM64 ATL.
    $builds = @(
        @{ Platform = "Win32";   Desc = "Win32 (x86 DLL + DIMESettings)" },
        @{ Platform = "x64";     Desc = "x64 (AMD64 DLL)" },
        @{ Platform = "ARM64EC"; Desc = "ARM64EC (ARM64 DLL)" }
    )

    foreach ($build in $builds) {
        Write-Host "Building Release|$($build.Platform) - $($build.Desc)..." -ForegroundColor Yellow

        # For ARM64EC, only build the DIME project (skip DIMETests which needs ARM64 ATL)
        if ($build.Platform -eq "ARM64EC") {
            & $msbuildExe $slnFile `
                /p:Configuration=Release `
                /p:Platform=$($build.Platform) `
                /p:PlatformToolset=v145 `
                /t:DIME `
                /nologo /v:minimal
        } else {
            & $msbuildExe $slnFile `
                /p:Configuration=Release `
                /p:Platform=$($build.Platform) `
                /p:PlatformToolset=v145 `
                /nologo /v:minimal
        }

        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Build failed for $($build.Platform)!" -ForegroundColor Red
            if (-not $NonInteractive) { Read-Host "Press Enter to exit" }
            exit 1
        }
        Write-Host "  $($build.Desc) built successfully!" -ForegroundColor Green
        Write-Host ""
    }

    # ==============================================================================
    # Step 3: Verify build artifacts
    # ==============================================================================
    Write-Host "Verifying build artifacts..." -ForegroundColor Yellow

    $artifacts = @(
        @{ Path = "$srcDir\Release\DIMESettings.exe"; Desc = "DIMESettings.exe" },
        @{ Path = "$srcDir\Release\x64\DIME.dll";     Desc = "DIME.dll (x64)" },
        @{ Path = "$srcDir\Release\Win32\DIME.dll";    Desc = "DIME.dll (Win32)" },
        @{ Path = "$srcDir\Release\ARM64EC\DIME.dll";  Desc = "DIME.dll (ARM64EC)" }
    )

    $allFound = $true
    foreach ($art in $artifacts) {
        if (Test-Path $art.Path) {
            $size = (Get-Item $art.Path).Length
            Write-Host "  OK: $($art.Desc) ($size bytes)" -ForegroundColor Green
        } else {
            Write-Host "  MISSING: $($art.Desc)" -ForegroundColor Red
            $allFound = $false
        }
    }

    if (-not $allFound) {
        Write-Host "ERROR: Some build artifacts are missing!" -ForegroundColor Red
        if (-not $NonInteractive) { Read-Host "Press Enter to exit" }
        exit 1
    }
    Write-Host ""

} else {
    Write-Host "Skipping build (-SkipBuild)." -ForegroundColor Yellow
    Write-Host ""
}

# ==============================================================================
# Step 4: Run deploy-wix-installer.ps1
# ==============================================================================
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host "Running WiX Installer Deployment..." -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host ""

$deployScript = "$repoRoot\installer\deploy-wix-installer.ps1"
$deployParams = @{}
if ($NonInteractive)      { $deployParams["NonInteractive"]     = $true }
if ($SkipChecksumUpdate)  { $deployParams["SkipChecksumUpdate"] = $true }

Push-Location "$repoRoot\installer"
try {
    & $deployScript @deployParams
} finally {
    Pop-Location
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: deploy-wix-installer.ps1 failed!" -ForegroundColor Red
    if (-not $NonInteractive) { Read-Host "Press Enter to exit" }
    exit 1
}

# ==============================================================================
# Summary
# ==============================================================================
$elapsed = (Get-Date) - $startTime
Write-Host ""
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host "All Done! ($('{0:mm\:ss}' -f $elapsed))" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Outputs in installer\:" -ForegroundColor Yellow
Write-Host "  - DIME-Universal.exe (Burn Bundle)" -ForegroundColor White
Write-Host "  - DIME-Universal.zip" -ForegroundColor White
Write-Host "  - DIME-64bit.msi" -ForegroundColor White
Write-Host "  - DIME-32bit.msi" -ForegroundColor White
Write-Host ""

if (-not $NonInteractive) { Read-Host "Press Enter to exit" }
