# Digititan - replace mobile\lib from GitHub branch ZIP
# Filename is NEW on purpose (avoids cached broken INSTALL-RESELLER-JOURNEY.ps1)
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. Run from S:\WORK\Digititan mobile app"
}

$zipUrl = "https://codeload.github.com/DigititanH/villagenetacad/zip/refs/heads/cursor/reseller-apply-client-pipeline-09ad"
$zipPath = Join-Path $env:TEMP "digititan-lib-sync.zip"
$extractRoot = Join-Path $env:TEMP "digititan-lib-sync"

Write-Host "Downloading branch ZIP..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -Headers @{ "Cache-Control" = "no-cache" }

if (Test-Path $extractRoot) { Remove-Item $extractRoot -Recurse -Force }
Expand-Archive -Path $zipPath -DestinationPath $extractRoot -Force

$repoRoot = Get-ChildItem $extractRoot -Directory | Select-Object -First 1
$libSrc = Join-Path $repoRoot.FullName "Digititan mobile app\mobile\lib"
if (-not (Test-Path $libSrc)) { Write-Error "Missing lib in zip: $libSrc" }

$libDest = Join-Path (Get-Location) "mobile\lib"
Write-Host "Replacing mobile\lib ..."
if (Test-Path $libDest) { Remove-Item $libDest -Recurse -Force }
Copy-Item $libSrc $libDest -Recurse -Force

$docsSrc = Join-Path $repoRoot.FullName "Digititan mobile app\docs"
$docsDest = Join-Path (Get-Location) "docs"
if (-not (Test-Path $docsDest)) { New-Item -ItemType Directory -Path $docsDest | Out-Null }
Copy-Item (Join-Path $docsSrc "18-RESELLER-CODES-AND-DUAL-ADMIN.md") $docsDest -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $docsSrc "19-LIVE-DEMO-RESELLER-ADMIN.md") $docsDest -Force -ErrorAction SilentlyContinue

$hasRef = Select-String -Path (Join-Path $libDest "domain\entities\shop_order.dart") -Pattern "referralCode" -SimpleMatch
$hasOps = Select-String -Path (Join-Path $libDest "presentation\shell\role_router.dart") -Pattern "opsAdmin" -SimpleMatch
if ($null -eq $hasRef -or $null -eq $hasOps) {
  Write-Error "Sync incomplete - shop_order/role_router still old."
}

Write-Host "SUCCESS - mobile\lib replaced." -ForegroundColor Green
Write-Host "Next:"
Write-Host "  cd mobile"
Write-Host "  flutter clean"
Write-Host "  flutter pub get"
Write-Host "  flutter run"
