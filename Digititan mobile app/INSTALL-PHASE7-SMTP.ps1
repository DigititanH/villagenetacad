# PHASE 7 - Dual SMTP mobile client (X-VNA-Client + client:mobile)
# Your PC may not have the git branch - this pulls from GitHub zip like Phase 8.
# Run from: S:\WORK\VillageNetAcad
# ASCII-only for Windows PowerShell 5.
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\VillageNetAcad (parent of mobile\)"
}

$branch = "cursor/phase7-smtp-app-uat-09ad"
$cacheBust = [int][double]::Parse((Get-Date -UFormat %s))
$zipUrl = "https://codeload.github.com/DigititanH/villagenetacad/zip/refs/heads/$branch" + "?t=$cacheBust"
$zipPath = Join-Path $env:TEMP "vna-phase7-smtp-$cacheBust.zip"
$extractRoot = Join-Path $env:TEMP "vna-phase7-smtp-$cacheBust"

Write-Host "Downloading Phase 7 SMTP app pack from DigititanH/${branch} ..." -ForegroundColor Cyan
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
Copy-Item (Join-Path $pack "docs\33-PHASE7-OTP-EMAIL-SMS.md") $docsDest -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $pack "docs\37-SMTP-AND-RESELLER-REGISTER-NOTES.md") $docsDest -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $pack "INSTALL-PHASE7-SMTP.ps1") (Get-Location) -Force -ErrorAction SilentlyContinue

$apiClient = Get-Content (Join-Path $libDest "infrastructure\api\api_client.dart") -Raw
if ($apiClient -notmatch "X-VNA-Client") {
  Write-Error "Stale api_client.dart - missing X-VNA-Client. Re-run INSTALL."
}
$authHttp = Get-Content (Join-Path $libDest "infrastructure\api\http_auth_repository.dart") -Raw
if ($authHttp -notmatch "'client': 'mobile'") {
  Write-Error "Stale http_auth_repository.dart - missing client:mobile. Re-run INSTALL."
}

Write-Host ""
Write-Host "SUCCESS - mobile lib has dual-SMTP client headers." -ForegroundColor Green
Write-Host ""
Write-Host "Run:" -ForegroundColor Yellow
Write-Host "  cd mobile"
Write-Host "  flutter pub get"
Write-Host "  flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za"
Write-Host ""
Write-Host "Then register a NEW customer email - welcome from app@ should arrive."
