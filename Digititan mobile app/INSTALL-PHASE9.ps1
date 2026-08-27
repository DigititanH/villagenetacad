# PHASE 9 - Courses photos + digital screens
# Run from: S:\WORK\VillageNetAcad
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\VillageNetAcad"
}

$branch = "cursor/phase9-wait-website-09ad"
# Cache-bust so Windows / CDN cannot serve a stale zip after a push.
# Use ${branch} — bare $branch?t= is parsed as PowerShell null-conditional.
$bust = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$zipUrl = "https://codeload.github.com/DigititanH/villagenetacad/zip/refs/heads/${branch}?t=${bust}"
$zipPath = Join-Path $env:TEMP ("vna-phase9-" + $bust + ".zip")
$extractRoot = Join-Path $env:TEMP ("vna-phase9-" + $bust)

Write-Host "Downloading Phase 9 (photos) from DigititanH/${branch} ..." -ForegroundColor Cyan
Write-Host "  $zipUrl"
if ($zipUrl -notmatch [regex]::Escape($branch)) {
  Write-Error "Installer bug: zip URL missing branch name: $zipUrl"
}
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -Headers @{
  "Cache-Control" = "no-cache"
  "Pragma" = "no-cache"
}

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

# Self-update this installer so next run shows the new messages
$installerSrc = Join-Path $pack "INSTALL-PHASE9.ps1"
if (Test-Path $installerSrc) {
  Copy-Item $installerSrc (Join-Path (Get-Location) "INSTALL-PHASE9.ps1") -Force
}

$docsDest = Join-Path (Get-Location) "docs"
if (-not (Test-Path $docsDest)) { New-Item -ItemType Directory -Path $docsDest | Out-Null }
Copy-Item (Join-Path $pack "docs\36-PHASE9-COURSES-SLICE-A.md") $docsDest -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $pack "docs\26-PRODUCT-BACKLOG-PHASES.md") $docsDest -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $pack "docs\12-LOCKED-DECISIONS.md") $docsDest -Force -ErrorAction SilentlyContinue

$checks = @(
  "infrastructure\courses\website_courses_catalogue.dart",
  "presentation\customer\training_detail_screen.dart",
  "presentation\customer\tabs\training_tab.dart",
  "presentation\customer\tabs\home_tab.dart",
  "presentation\customer\widgets\course_image.dart"
)
foreach ($rel in $checks) {
  $p = Join-Path $libDest $rel
  if (-not (Test-Path $p)) { Write-Error "Missing after sync: $rel" }
}

# Hard proof the photo cards landed (app light theme — not website dark)
$tab = Join-Path $libDest "presentation\customer\tabs\training_tab.dart"
$img = Join-Path $libDest "presentation\customer\widgets\course_image.dart"
$tabText = Get-Content $tab -Raw
$imgText = Get-Content $img -Raw
if ($tabText -notmatch "CourseDigitalTile") {
  Write-Error "Sync incomplete: training_tab.dart missing CourseDigitalTile"
}
if ($tabText -notmatch "DigititanColors.background") {
  Write-Error "Sync incomplete: training_tab.dart missing app light theme"
}
if ($tabText -match "0xFF0B1220") {
  Write-Error "Sync incomplete: training_tab.dart still has website dark theme"
}
if ($imgText -notmatch "CourseDigitalTile") {
  Write-Error "Sync incomplete: course_image.dart missing CourseDigitalTile"
}

# Cleanup temp zip (best-effort)
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
Remove-Item $extractRoot -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "SUCCESS - Phase 9 courses (photos + app light theme) synced." -ForegroundColor Green
Write-Host "Proof: CourseDigitalTile + DigititanColors.background (matches Home/Store)." -ForegroundColor Green
Write-Host ""
Write-Host "STOP the running app completely (hot reload will NOT pick this up)." -ForegroundColor Yellow
Write-Host "Then:"
Write-Host "  cd mobile"
Write-Host "  flutter pub get"
Write-Host "  flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za"
Write-Host ""
Write-Host "You MUST see: light Courses screen (same as Home/Store) + photo cards." -ForegroundColor Cyan
Write-Host "If Courses is still dark blue, sync failed — re-download INSTALL-PHASE9.ps1."
Write-Host "See docs\36-PHASE9-COURSES-SLICE-A.md"
