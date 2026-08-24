# Presentation frontend clean — theme, login, Home/Store/Profile, reseller/admin polish
# Run from: S:\WORK\Digititan mobile app
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\Digititan mobile app"
}

$branch = "cursor/presentation-frontend-clean-09ad"
$zipUrl = "https://codeload.github.com/DigititanH/villagenetacad/zip/refs/heads/$branch"
$zipPath = Join-Path $env:TEMP "digititan-presentation-clean.zip"
$extractRoot = Join-Path $env:TEMP "digititan-presentation-clean"

Write-Host "Downloading presentation polish branch ZIP..."
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

$brandSrc = Join-Path $repoRoot.FullName "Digititan mobile app\mobile\assets\branding"
$brandDest = Join-Path (Get-Location) "mobile\assets\branding"
if (Test-Path $brandSrc) {
  if (-not (Test-Path $brandDest)) { New-Item -ItemType Directory -Path $brandDest -Force | Out-Null }
  Copy-Item (Join-Path $brandSrc "*") $brandDest -Force
}

$hit = Select-String -Path (Join-Path $libDest "presentation\auth\login_screen.dart") -Pattern "Demo login details" -SimpleMatch
if ($null -eq $hit) { Write-Error "Sync failed - login polish missing." }

Write-Host "SUCCESS - presentation frontend clean synced." -ForegroundColor Green
Write-Host "  cd mobile"
Write-Host "  flutter clean"
Write-Host "  flutter pub get"
Write-Host "  flutter run"
Write-Host "Full restart required for theme + assets."
