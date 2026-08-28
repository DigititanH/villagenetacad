# PHASE 8 SLICE 2 - Ledger + clients + statement (+ live Ops Admin)
# Run from: S:\WORK\VillageNetAcad
# ASCII-only for Windows PowerShell 5.
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\VillageNetAcad"
}

$branch = "cursor/phase8-ledger-clients-09ad"
# Bust CDN/cache so Windows always gets the latest branch tip.
$cacheBust = [int][double]::Parse((Get-Date -UFormat %s))
$zipUrl = "https://codeload.github.com/DigititanH/villagenetacad/zip/refs/heads/$branch" + "?t=$cacheBust"
$zipPath = Join-Path $env:TEMP "vna-phase8-ledger-$cacheBust.zip"
$extractRoot = Join-Path $env:TEMP "vna-phase8-ledger-$cacheBust"

Write-Host "Downloading Phase 8 from DigititanH/${branch} (t=$cacheBust) ..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -Headers @{ "Cache-Control" = "no-cache"; "Pragma" = "no-cache" }

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
Copy-Item (Join-Path $pack "docs\38-PHASE8-LEDGER-CLIENTS.md") $docsDest -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $pack "docs\35-PHASE8-RESELLER-PRODUCTION.md") $docsDest -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $pack "docs\26-PRODUCT-BACKLOG-PHASES.md") $docsDest -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $pack "docs\39-ROLE-SMOKE-UAT.md") $docsDest -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $pack "INSTALL-PHASE8-LEDGER.ps1") (Get-Location) -Force -ErrorAction SilentlyContinue

$checks = @(
  "infrastructure\api\http_reseller_repository.dart",
  "infrastructure\api\http_admin_repository.dart",
  "infrastructure\dummy\dummy_reseller_repository.dart",
  "domain\entities\withdrawal_request.dart",
  "presentation\reseller\reseller_shell.dart"
)
foreach ($rel in $checks) {
  $p = Join-Path $libDest $rel
  if (-not (Test-Path $p)) { Write-Error "Missing after sync: $rel" }
}

$resellerDart = Get-Content (Join-Path $libDest "infrastructure\dummy\dummy_reseller_repository.dart") -Raw
if ($resellerDart -notmatch "withdrawal_request\.dart") {
  Write-Error "Stale lib: dummy_reseller_repository.dart missing withdrawal_request import. Re-run INSTALL."
}

Write-Host ""
Write-Host "SUCCESS - Phase 8 lib is on this machine (incl. live Ops Admin)." -ForegroundColor Green
Write-Host ""
Write-Host "Run:" -ForegroundColor Yellow
Write-Host "  cd mobile"
Write-Host "  flutter pub get"
Write-Host "  flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za"
Write-Host ""
Write-Host "See docs\38-PHASE8-LEDGER-CLIENTS.md and docs\39-ROLE-SMOKE-UAT.md"
