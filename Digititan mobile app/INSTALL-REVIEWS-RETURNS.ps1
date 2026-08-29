# Reviews + returns — sync Flutter from GitHub zip
# Run from: S:\WORK\VillageNetAcad
# ASCII-only for Windows PowerShell 5.
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\VillageNetAcad (parent of mobile\)"
}

$branch = "cursor/customer-reviews-returns-09ad"
$cacheBust = [int][double]::Parse((Get-Date -UFormat %s))
$zipUrl = "https://codeload.github.com/DigititanH/villagenetacad/zip/refs/heads/$branch" + "?t=$cacheBust"
$zipPath = Join-Path $env:TEMP "vna-reviews-returns-$cacheBust.zip"
$extractRoot = Join-Path $env:TEMP "vna-reviews-returns-$cacheBust"

Write-Host "Downloading reviews/returns pack from DigititanH/${branch} ..." -ForegroundColor Cyan
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

Copy-Item (Join-Path $pack "INSTALL-REVIEWS-RETURNS.ps1") (Get-Location) -Force -ErrorAction SilentlyContinue
$docsDest = Join-Path (Get-Location) "docs"
if (-not (Test-Path $docsDest)) { New-Item -ItemType Directory -Path $docsDest | Out-Null }
Copy-Item (Join-Path $pack "docs\38-REVIEWS-RETURNS.md") $docsDest -Force -ErrorAction SilentlyContinue

$httpStore = Get-Content (Join-Path $libDest "infrastructure\api\http_store_repository.dart") -Raw
if ($httpStore -match "later phase") {
  Write-Error "Stale http_store_repository.dart - still has later-phase stubs. Re-run INSTALL."
}
if ($httpStore -notmatch "/api/orders/\$rawId/review") {
  Write-Error "Stale http_store_repository.dart - missing review endpoint. Re-run INSTALL."
}

Write-Host ""
Write-Host "SUCCESS - mobile lib has live review + return APIs." -ForegroundColor Green
Write-Host ""
Write-Host "Also upload deploy/phase-reviews-returns-live to Afrihost (migration + PHP)." -ForegroundColor Yellow
Write-Host "Run:" -ForegroundColor Yellow
Write-Host "  cd mobile"
Write-Host "  flutter pub get"
Write-Host "  flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za"
Write-Host ""
Write-Host "UAT: delivered order -> Leave a review / Request return."
