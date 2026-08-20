# Full sync: download branch ZIP and replace mobile\lib (fixes partial-sync build errors).
# Run from: S:\WORK\Digititan mobile app
$ErrorActionPreference = "Stop"

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\Digititan mobile app then rerun."
}

$zipUrl = "https://codeload.github.com/DigititanH/villagenetacad/zip/refs/heads/cursor/reseller-apply-client-pipeline-09ad"
$zipPath = Join-Path $env:TEMP "digititan-reseller-journey.zip"
$extractRoot = Join-Path $env:TEMP "digititan-reseller-journey"

Write-Host "Downloading reseller journey branch zip..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

if (Test-Path $extractRoot) {
  Remove-Item $extractRoot -Recurse -Force
}
Expand-Archive -Path $zipPath -DestinationPath $extractRoot -Force

$repoRoot = Get-ChildItem $extractRoot -Directory | Select-Object -First 1
if ($null -eq $repoRoot) {
  Write-Error "Zip extract failed - no folder found."
}

$libSrc = Join-Path $repoRoot.FullName "Digititan mobile app\mobile\lib"
$docsSrc = Join-Path $repoRoot.FullName "Digititan mobile app\docs"
if (-not (Test-Path $libSrc)) {
  Write-Error "Unexpected zip layout. Missing: $libSrc"
}

# Prove critical files exist before replacing
$mustHave = @(
  "domain\entities\shop_order.dart",
  "domain\repositories\admin_repository.dart",
  "presentation\shell\role_router.dart",
  "presentation\customer\payment_otp_screen.dart",
  "infrastructure\dummy\demo_hub.dart"
)
foreach ($rel in $mustHave) {
  $p = Join-Path $libSrc $rel
  if (-not (Test-Path $p)) {
    Write-Error "Zip missing required file: $rel"
  }
}

$libDest = Join-Path (Get-Location) "mobile\lib"
Write-Host "Replacing $libDest ..."
if (Test-Path $libDest) {
  Remove-Item $libDest -Recurse -Force
}
Copy-Item $libSrc $libDest -Recurse -Force

$docsDest = Join-Path (Get-Location) "docs"
if (-not (Test-Path $docsDest)) {
  New-Item -ItemType Directory -Path $docsDest | Out-Null
}
Copy-Item (Join-Path $docsSrc "18-RESELLER-CODES-AND-DUAL-ADMIN.md") $docsDest -Force
Copy-Item (Join-Path $docsSrc "19-LIVE-DEMO-RESELLER-ADMIN.md") $docsDest -Force

# Sanity check on laptop copy
$check = Select-String -Path (Join-Path $libDest "domain\entities\shop_order.dart") -Pattern "referralCode" -SimpleMatch
if ($null -eq $check) {
  Write-Error "After copy, shop_order.dart still has no referralCode - sync failed."
}
$check2 = Select-String -Path (Join-Path $libDest "presentation\shell\role_router.dart") -Pattern "opsAdmin" -SimpleMatch
if ($null -eq $check2) {
  Write-Error "After copy, role_router.dart still has no opsAdmin - sync failed."
}

Write-Host ""
Write-Host "SUCCESS - mobile\lib fully replaced from GitHub branch." -ForegroundColor Green
Write-Host '  cd "S:\WORK\Digititan mobile app\mobile"'
Write-Host "  flutter clean"
Write-Host "  flutter pub get"
Write-Host "  flutter run"
