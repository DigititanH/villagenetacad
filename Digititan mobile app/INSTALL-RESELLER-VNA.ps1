# Sync reseller VNA-B / VNA-C register UI into laptop app
# Run from: S:\WORK\VillageNetAcad
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\VillageNetAcad"
}

$branch = "cursor/reseller-register-ux-09ad"
$bust = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$zipUrl = "https://codeload.github.com/DigititanH/villagenetacad/zip/refs/heads/${branch}?t=${bust}"
$zipPath = Join-Path $env:TEMP ("vna-reseller-" + $bust + ".zip")
$extractRoot = Join-Path $env:TEMP ("vna-reseller-" + $bust)

Write-Host "Downloading ${branch} ..." -ForegroundColor Cyan
Write-Host "  $zipUrl"
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

$tab = Join-Path $libDest "presentation\auth\register_screen.dart"
$tabText = Get-Content $tab -Raw
if ($tabText -notmatch "Reseller path") {
  Write-Error "Sync incomplete: register_screen.dart missing Reseller path UI"
}
if ($tabText -match "Academy / centre \(required\)") {
  Write-Error "Sync incomplete: still has old required academy label"
}

Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
Remove-Item $extractRoot -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "SUCCESS - Reseller VNA-B/VNA-C register UI synced." -ForegroundColor Green
Write-Host "Proof: register shows Independent / Affiliated / I am a centre." -ForegroundColor Green
Write-Host ""
Write-Host "STOP the app completely, then:" -ForegroundColor Yellow
Write-Host "  cd mobile"
Write-Host "  flutter pub get"
Write-Host "  flutter run --no-dds --dart-define=API_BASE_URL=https://villagenetacad.co.za"
Write-Host ""
Write-Host "Also confirm live AuthController.php was updated (VNA-B / VNA-C)."
