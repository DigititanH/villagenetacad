# PHASE 10 - Ops Admin live (no SMTP)
# Run from: S:\WORK\VillageNetAcad
# ASCII-only for Windows PowerShell 5.
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\VillageNetAcad"
}

$branch = "cursor/phase10-ops-admin-09ad"
$zipUrl = "https://codeload.github.com/DigititanH/villagenetacad/zip/refs/heads/$branch"
$zipPath = Join-Path $env:TEMP "vna-phase10.zip"
$extractRoot = Join-Path $env:TEMP "vna-phase10"

Write-Host "Downloading Phase 10 from DigititanH/${branch} ..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -Headers @{ "Cache-Control" = "no-cache" }

if (Test-Path $extractRoot) { Remove-Item $extractRoot -Recurse -Force }
Expand-Archive -Path $zipPath -DestinationPath $extractRoot -Force

$repoRoot = Get-ChildItem $extractRoot -Directory | Select-Object -First 1
$pack = Join-Path $repoRoot.FullName "Digititan mobile app"
$libSrc = Join-Path $pack "mobile\lib"
$libDest = Join-Path (Get-Location) "mobile\lib"
if (-not (Test-Path $libSrc)) { Write-Error "Missing lib in zip: $libSrc" }

Write-Host "Replacing mobile\lib ..."
if (Test-Path $libDest) { Remove-Item $libDest -Recurse -Force }
Copy-Item $libSrc $libDest -Recurse -Force

$pubSrc = Join-Path $pack "mobile\pubspec.yaml"
$pubLock = Join-Path $pack "mobile\pubspec.lock"
Copy-Item $pubSrc (Join-Path (Get-Location) "mobile\pubspec.yaml") -Force
if (Test-Path $pubLock) {
  Copy-Item $pubLock (Join-Path (Get-Location) "mobile\pubspec.lock") -Force
}

$docsDest = Join-Path (Get-Location) "docs"
if (-not (Test-Path $docsDest)) { New-Item -ItemType Directory -Path $docsDest | Out-Null }
Copy-Item (Join-Path $pack "docs\39-PHASE10-OPS-ADMIN.md") $docsDest -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $pack "docs\26-PRODUCT-BACKLOG-PHASES.md") $docsDest -Force -ErrorAction SilentlyContinue

$checks = @(
  "infrastructure\api\http_admin_repository.dart",
  "presentation\admin\admin_shell.dart",
  "presentation\customer\notifications_screen.dart",
  "app\injection.dart"
)
foreach ($rel in $checks) {
  $p = Join-Path $libDest $rel
  if (-not (Test-Path $p)) { Write-Error "Missing after sync: $rel" }
}

Write-Host ""
Write-Host "SUCCESS - Phase 10 Ops Admin lib is on this machine." -ForegroundColor Green
Write-Host ""
Write-Host "Run:" -ForegroundColor Yellow
Write-Host "  cd mobile"
Write-Host "  flutter pub get"
Write-Host "  flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za"
Write-Host ""
Write-Host "Login with a live website admin account (role=admin)."
Write-Host "No SMTP / no phpMyAdmin for this slice."
Write-Host "See docs\39-PHASE10-OPS-ADMIN.md"
