# PHASE 2 — Finish the presentation story (+ Wave 2 demo items)
# Run from: S:\WORK\VillageNetAcad
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\VillageNetAcad"
}

$branch = "cursor/phase2-presentation-story-09ad"
$zipUrl = "https://codeload.github.com/DigititanH/villagenetacad/zip/refs/heads/$branch"
$zipPath = Join-Path $env:TEMP "vna-phase2.zip"
$extractRoot = Join-Path $env:TEMP "vna-phase2"

Write-Host "Downloading Phase 2 from DigititanH/$branch ..." -ForegroundColor Cyan
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

$docsDest = Join-Path (Get-Location) "docs"
if (-not (Test-Path $docsDest)) { New-Item -ItemType Directory -Path $docsDest | Out-Null }
Copy-Item (Join-Path $pack "docs\26-PRODUCT-BACKLOG-PHASES.md") $docsDest -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $pack "docs\27-PHASE2-PRESENTATION-STORY.md") $docsDest -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $pack "docs\12-LOCKED-DECISIONS.md") $docsDest -Force -ErrorAction SilentlyContinue

$checks = @(
  "presentation\customer\verify_reseller_screen.dart",
  "presentation\customer\return_request_screen.dart",
  "presentation\customer\review_order_screen.dart",
  "presentation\customer\ambassador_apply_screen.dart",
  "presentation\customer\academy_performance_screen.dart",
  "presentation\auth\otp_channel_picker.dart",
  "presentation\reseller\reseller_qr_card.dart"
)
foreach ($rel in $checks) {
  $p = Join-Path $libDest $rel
  if (-not (Test-Path $p)) { Write-Error "Missing after sync: $rel" }
}

Write-Host ""
Write-Host "SUCCESS - Phase 2 is on this machine." -ForegroundColor Green
Write-Host "Demo walk:"
Write-Host "  customer@demo.com / demo123"
Write-Host "  My orders -> ORD-DEMO-DELIVERED -> Return + Review"
Write-Host "  Profile -> Verify reseller -> VNA-B-LERATO"
Write-Host "  Reseller -> QR card"
Write-Host "  Academies -> leaderboard icon"
Write-Host "  Training interest -> gender field"
Write-Host "  OTP screens -> Email/SMS picker"
Write-Host ""
Write-Host "  cd mobile"
Write-Host "  flutter clean"
Write-Host "  flutter pub get"
Write-Host "  flutter run"
