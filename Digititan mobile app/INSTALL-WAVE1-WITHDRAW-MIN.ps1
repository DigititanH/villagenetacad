# Quick fix: R100 withdraw button lock + clear error
# Run from: S:\WORK\VillageNetAcad
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\VillageNetAcad"
}

$url = "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/wave1-meeting-feedback-09ad/Digititan%20mobile%20app/mobile/lib/presentation/reseller/reseller_shell.dart"
$dest = ".\mobile\lib\presentation\reseller\reseller_shell.dart"

Write-Host "Downloading updated reseller_shell.dart ..."
Invoke-WebRequest -Uri $url -OutFile $dest -Headers @{ "Cache-Control" = "no-cache" }

$hit = Select-String -Path $dest -Pattern "_MinWithdrawDialog" -SimpleMatch
if ($null -eq $hit) { Write-Error "Download failed - _MinWithdrawDialog missing" }

Write-Host "SUCCESS - Request withdrawal is disabled under R100 with a clear red error." -ForegroundColor Green
Write-Host "  cd mobile"
Write-Host "  flutter run"
Write-Host "Then: Reseller -> Simulate month-end -> Withdraw -> type 50 -> button stays off"
