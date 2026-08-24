# Decode + run clickable store link installer
# Run from: S:\WORK\Digititan mobile app
$ErrorActionPreference = "Stop"
if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\Digititan mobile app first."
}
if (-not (Test-Path ".\clickable-store-link.b64")) {
  Write-Error "Missing clickable-store-link.b64 next to this script."
}
$out = ".\INSTALL-CLICKABLE-STORE-LINK.ps1"
$bytes = [Convert]::FromBase64String((Get-Content ".\clickable-store-link.b64" -Raw).Trim())
[System.IO.File]::WriteAllBytes((Join-Path (Get-Location) "INSTALL-CLICKABLE-STORE-LINK.ps1"), $bytes)
Write-Host "Wrote INSTALL-CLICKABLE-STORE-LINK.ps1"
powershell -ExecutionPolicy Bypass -File $out
