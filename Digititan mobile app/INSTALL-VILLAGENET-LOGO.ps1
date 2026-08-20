# Point login/brand header at VillageNetAcadTransparentBackground.png
# Run from: S:\WORK\Digititan mobile app
# Requires file already at:
#   mobile\assets\branding\VillageNetAcadTransparentBackground.png
$ErrorActionPreference = "Stop"
if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\Digititan mobile app then rerun."
}

$logoRel = "mobile\assets\branding\VillageNetAcadTransparentBackground.png"
if (-not (Test-Path $logoRel)) {
  Write-Error "Missing $logoRel - copy the PNG there first."
}

$root = (Get-Location).Path
$header = Join-Path $root "mobile\lib\shared\theme\digititan_brand_header.dart"
if (-not (Test-Path $header)) {
  Write-Error "Missing brand header. Run INSTALL-BRANDING.ps1 first."
}

$dart = Get-Content $header -Raw
$dart = $dart -replace "assets/branding/VillageNetAcadBackground\.png", "assets/branding/VillageNetAcadTransparentBackground.png"
$dart = $dart -replace "assets/branding/logo\.png", "assets/branding/VillageNetAcadTransparentBackground.png"
$dart = $dart -replace "BoxFit\.cover", "BoxFit.contain"
[System.IO.File]::WriteAllText($header, $dart)
Write-Host "Updated digititan_brand_header.dart"

$pub = Join-Path $root "mobile\pubspec.yaml"
$txt = Get-Content $pub -Raw
$assetLine = "assets/branding/VillageNetAcadTransparentBackground.png"
if ($txt -notmatch [regex]::Escape($assetLine)) {
  if ($txt -match "(?m)^\s*assets:\s*$") {
    $txt = $txt -replace '(?m)(^\s*assets:\s*$)', "`$1`r`n    - $assetLine"
  } elseif ($txt -match "(?m)^flutter:\s*") {
    $txt = $txt -replace '(?m)^(flutter:\s*)$', "`$1`r`n  assets:`r`n    - $assetLine"
  } else {
    $txt = $txt.TrimEnd() + "`r`nflutter:`r`n  assets:`r`n    - $assetLine`r`n"
  }
  [System.IO.File]::WriteAllText($pub, $txt)
  Write-Host "Registered $assetLine in pubspec.yaml"
} else {
  Write-Host "pubspec already lists VillageNetAcadTransparentBackground.png"
}

Push-Location (Join-Path $root "mobile")
flutter pub get | Out-Host
Pop-Location

Write-Host ""
Write-Host "SUCCESS - Logo set to VillageNetAcadTransparentBackground.png" -ForegroundColor Green
Write-Host '  cd "S:\WORK\Digititan mobile app\mobile"'
Write-Host "  flutter run"
