# PHASE 4 — Shared accounts (HTTP auth + JWT)
# Run from: S:\WORK\VillageNetAcad
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\VillageNetAcad"
}

$branch = "cursor/phase4-shared-accounts-09ad"
$zipUrl = "https://codeload.github.com/DigititanH/villagenetacad/zip/refs/heads/$branch"
$zipPath = Join-Path $env:TEMP "vna-phase4.zip"
$extractRoot = Join-Path $env:TEMP "vna-phase4"

Write-Host "Downloading Phase 4 from DigititanH/$branch ..." -ForegroundColor Cyan
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

# Keep compileSdk compatible if a future plugin asks for 37; do not force 37
# (Android Platform "37.0" folder naming can break Gradle android-37 lookup).
$gradleKts = Join-Path (Get-Location) "mobile\android\app\build.gradle.kts"
$gradleGroovy = Join-Path (Get-Location) "mobile\android\app\build.gradle"
foreach ($gf in @($gradleKts, $gradleGroovy)) {
  if (-not (Test-Path $gf)) { continue }
  $text = Get-Content $gf -Raw
  if ($text -match 'compileSdk\s*=\s*37' -or $text -match 'compileSdkVersion\s*=?\s*37') {
    Write-Host "Leaving compileSdk 37 as-is in $(Split-Path $gf -Leaf)"
  }
}

$docsDest = Join-Path (Get-Location) "docs"
if (-not (Test-Path $docsDest)) { New-Item -ItemType Directory -Path $docsDest | Out-Null }
Copy-Item (Join-Path $pack "docs\29-PHASE4-SHARED-ACCOUNTS.md") $docsDest -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $pack "docs\26-PRODUCT-BACKLOG-PHASES.md") $docsDest -Force -ErrorAction SilentlyContinue

$checks = @(
  "infrastructure\api\api_client.dart",
  "infrastructure\api\http_auth_repository.dart",
  "infrastructure\api\token_store.dart",
  "shared\config\app_config.dart"
)
foreach ($rel in $checks) {
  $p = Join-Path $libDest $rel
  if (-not (Test-Path $p)) { Write-Error "Missing after sync: $rel" }
}

Write-Host ""
Write-Host "SUCCESS - Phase 4 lib is on this machine." -ForegroundColor Green
Write-Host ""
Write-Host "BEFORE flutter run (Windows):" -ForegroundColor Yellow
Write-Host "  1) Enable Developer Mode (symlink support for plugins):"
Write-Host "       start ms-settings:developers"
Write-Host "  2) Start backend in Terminal A (must actually be listening on :5000)."
Write-Host ""
Write-Host "Default: dummy auth (decks) — flutter run with NO API_BASE_URL."
Write-Host "Live API (Android emulator → host):"
Write-Host "  cd mobile"
Write-Host "  flutter pub get"
Write-Host "  flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000"
Write-Host ""
Write-Host "If build still mentions android-37: flutter_secure_storage is pinned to ^9.2.4 (SDK 36 OK)."
Write-Host "See docs\29-PHASE4-SHARED-ACCOUNTS.md"
