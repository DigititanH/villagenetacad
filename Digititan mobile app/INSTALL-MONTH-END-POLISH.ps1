# Month-end polish: splits 53-26-21 + Home/Academies/Ops promo
# Run from: S:\WORK\Digititan mobile app
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\Digititan mobile app"
}

$zipUrl = "https://codeload.github.com/DigititanH/villagenetacad/zip/refs/heads/cursor/month-end-polish-splits-09ad"
$zipPath = Join-Path $env:TEMP "digititan-month-end-polish.zip"
$extractRoot = Join-Path $env:TEMP "digititan-month-end-polish"

Write-Host "Downloading month-end polish branch ZIP..."
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
Copy-Item (Join-Path $docsSrc "12-LOCKED-DECISIONS.md") $docsDest -Force
Copy-Item (Join-Path $docsSrc "18-RESELLER-CODES-AND-DUAL-ADMIN.md") $docsDest -Force

$checkFile = Join-Path $libDest "domain\entities\revenue_split.dart"
$hit = Select-String -Path $checkFile -Pattern "beneficiaryPercent = 53" -SimpleMatch
if ($null -eq $hit) { Write-Error "Sync failed - revenue_split.dart missing 53 percent." }

$promoHit = Select-String -Path (Join-Path $libDest "domain\entities\product.dart") -Pattern "compareAtPrice" -SimpleMatch
if ($null -eq $promoHit) { Write-Error "Sync failed - product.dart missing compareAtPrice." }

Write-Host "SUCCESS - month-end polish synced." -ForegroundColor Green
Write-Host "Includes: 53/26/21 splits, Home, Academies, Ops, promo strikethrough prices."
Write-Host "  cd mobile"
Write-Host "  flutter clean"
Write-Host "  flutter pub get"
Write-Host "  flutter run"
