# START-LOCAL-API.ps1
# VillageNetAcad on S: is mobile-only (no package.json).
# This pulls DigititanH backend-php into .\local-api and starts PHP on :5000.
# Requires: php on PATH, MySQL with village_netacad (see docs).
# Run from: S:\WORK\VillageNetAcad
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\VillageNetAcad"
}

$php = Get-Command php -ErrorAction SilentlyContinue
if (-not $php) {
  Write-Host "PHP not found on PATH." -ForegroundColor Red
  Write-Host "Install: winget install --id PHP.PHP.8.3 -e"
  Write-Host "Or skip local API and point the app at production:"
  Write-Host "  flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za"
  exit 1
}

$branch = "cursor/phase4-shared-accounts-09ad"
$zipUrl = "https://codeload.github.com/DigititanH/villagenetacad/zip/refs/heads/$branch"
$zipPath = Join-Path $env:TEMP "vna-backend.zip"
$extractRoot = Join-Path $env:TEMP "vna-backend"
$dest = Join-Path (Get-Location) "local-api"

Write-Host "Downloading backend-php from DigititanH/$branch ..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -Headers @{ "Cache-Control" = "no-cache" }
if (Test-Path $extractRoot) { Remove-Item $extractRoot -Recurse -Force }
Expand-Archive -Path $zipPath -DestinationPath $extractRoot -Force

$repoRoot = Get-ChildItem $extractRoot -Directory | Select-Object -First 1
$src = Join-Path $repoRoot.FullName "backend-php"
if (-not (Test-Path $src)) { Write-Error "backend-php missing in zip" }

if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
Copy-Item $src $dest -Recurse -Force

$envFile = Join-Path $dest ".env"
$envExample = Join-Path $dest ".env.example"
if (-not (Test-Path $envFile) -and (Test-Path $envExample)) {
  Copy-Item $envExample $envFile
  Write-Host "Created local-api\.env from .env.example - edit DB_PASSWORD if needed." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Starting PHP on http://0.0.0.0:5000 (leave this window open)" -ForegroundColor Green
Write-Host "Health check in another terminal: Invoke-WebRequest http://127.0.0.1:5000/health"
Write-Host "App (emulator): flutter run --no-dds --dart-define=API_BASE_URL=http://10.0.2.2:5000"
Write-Host ""

Set-Location $dest
# Router script is public/index.php (DigititanH layout)
php -S 0.0.0.0:5000 -t public public/index.php
