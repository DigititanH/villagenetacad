# WAVE 1 — Meeting feedback 24 Aug 2026
# Bigger logo · R100 min withdraw · Legal drafts · Academy register · App icon
#
# Run from your REAL mobile repo:
#   cd S:\WORK\VillageNetAcad
#   powershell -ExecutionPolicy Bypass -File .\INSTALL-WAVE1.ps1
#
# (Also works if you run it from S:\WORK\Digititan mobile app)

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$here = (Get-Location).Path
if (-not (Test-Path (Join-Path $here "mobile\pubspec.yaml"))) {
  Write-Error "Wrong folder. cd to S:\WORK\VillageNetAcad (must contain mobile\pubspec.yaml)"
}

$branch = "cursor/wave1-meeting-feedback-09ad"
$zipUrl = "https://codeload.github.com/DigititanH/villagenetacad/zip/refs/heads/$branch"
$zipPath = Join-Path $env:TEMP "vna-wave1.zip"
$extractRoot = Join-Path $env:TEMP "vna-wave1"

Write-Host "Downloading Wave 1 from DigititanH/$branch ..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -Headers @{ "Cache-Control" = "no-cache" }

if (Test-Path $extractRoot) { Remove-Item $extractRoot -Recurse -Force }
Expand-Archive -Path $zipPath -DestinationPath $extractRoot -Force

$repoRoot = Get-ChildItem $extractRoot -Directory | Select-Object -First 1
$pack = Join-Path $repoRoot.FullName "Digititan mobile app"
if (-not (Test-Path $pack)) { Write-Error "Missing Digititan mobile app folder in zip" }

# --- lib (full replace) ---
$libSrc = Join-Path $pack "mobile\lib"
$libDest = Join-Path $here "mobile\lib"
if (-not (Test-Path $libSrc)) { Write-Error "Missing lib in zip: $libSrc" }
Write-Host "Replacing mobile\lib ..."
if (Test-Path $libDest) { Remove-Item $libDest -Recurse -Force }
Copy-Item $libSrc $libDest -Recurse -Force

# --- docs ---
$docsDest = Join-Path $here "docs"
if (-not (Test-Path $docsDest)) { New-Item -ItemType Directory -Path $docsDest | Out-Null }
Copy-Item (Join-Path $pack "docs\12-LOCKED-DECISIONS.md") $docsDest -Force
Copy-Item (Join-Path $pack "docs\22-WAVE1-MEETING-FEEDBACK.md") $docsDest -Force

# --- pubspec (launcher icons config) ---
Copy-Item (Join-Path $pack "mobile\pubspec.yaml") (Join-Path $here "mobile\pubspec.yaml") -Force

# --- Android icons ---
$androidResSrc = Join-Path $pack "mobile\android\app\src\main\res"
$androidResDest = Join-Path $here "mobile\android\app\src\main\res"
if (Test-Path $androidResSrc) {
  Write-Host "Updating Android launcher icons ..."
  if (-not (Test-Path (Split-Path $androidResDest -Parent))) {
    New-Item -ItemType Directory -Path (Split-Path $androidResDest -Parent) -Force | Out-Null
  }
  if (Test-Path $androidResDest) { Remove-Item $androidResDest -Recurse -Force }
  Copy-Item $androidResSrc $androidResDest -Recurse -Force
}

# --- iOS AppIcon ---
$iosIconSrc = Join-Path $pack "mobile\ios\Runner\Assets.xcassets\AppIcon.appiconset"
$iosIconDest = Join-Path $here "mobile\ios\Runner\Assets.xcassets\AppIcon.appiconset"
if (Test-Path $iosIconSrc) {
  Write-Host "Updating iOS AppIcon ..."
  $iosParent = Split-Path $iosIconDest -Parent
  if (-not (Test-Path $iosParent)) { New-Item -ItemType Directory -Path $iosParent -Force | Out-Null }
  if (Test-Path $iosIconDest) { Remove-Item $iosIconDest -Recurse -Force }
  Copy-Item $iosIconSrc $iosIconDest -Recurse -Force
}

# --- verify markers ---
$login = Join-Path $libDest "presentation\auth\login_screen.dart"
$cfg = Join-Path $libDest "shared\config\app_config.dart"
$legal = Join-Path $libDest "presentation\customer\legal_hub_screen.dart"
$org = Join-Path $libDest "presentation\customer\organisation_register_screen.dart"

if (-not (Select-String -Path $login -Pattern "hero: true" -SimpleMatch)) {
  Write-Error "Sync failed - login logo hero missing"
}
if (-not (Select-String -Path $cfg -Pattern "minWithdrawalZar = 100" -SimpleMatch)) {
  Write-Error "Sync failed - minWithdrawalZar missing"
}
if (-not (Test-Path $legal)) { Write-Error "Sync failed - legal_hub_screen.dart missing" }
if (-not (Select-String -Path $org -Pattern "Register with Digititan first" -SimpleMatch)) {
  Write-Error "Sync failed - academy Digititan-first copy missing"
}

Write-Host ""
Write-Host "SUCCESS - Wave 1 is now on this machine." -ForegroundColor Green
Write-Host "  1) Bigger login logo"
Write-Host "  2) Min withdraw R100"
Write-Host "  3) Profile -> Legal & privacy"
Write-Host "  4) Academies -> + -> Register academy / org"
Write-Host "  5) Village NetAcad app icon"
Write-Host ""
Write-Host "Next:"
Write-Host "  cd mobile"
Write-Host "  flutter clean"
Write-Host "  flutter pub get"
Write-Host "  flutter run"
Write-Host ""
Write-Host "Then push yourself:"
Write-Host "  git checkout -b cursor/wave1-meeting-feedback-09ad"
Write-Host "  git add -A"
Write-Host '  git commit -m "Wave 1 meeting feedback"'
Write-Host "  git push -u origin cursor/wave1-meeting-feedback-09ad"
