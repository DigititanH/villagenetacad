# Sync product backlog (Waves folded into Phases 1-12)
# Run from: S:\WORK\VillageNetAcad
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\VillageNetAcad"
}
if (-not (Test-Path ".\docs")) { New-Item -ItemType Directory -Path ".\docs" | Out-Null }
$base = "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/wave1-meeting-feedback-09ad/Digititan%20mobile%20app/docs"
Invoke-WebRequest -Uri "$base/26-PRODUCT-BACKLOG-PHASES.md" -OutFile ".\docs\26-PRODUCT-BACKLOG-PHASES.md" -Headers @{ "Cache-Control" = "no-cache" }
Invoke-WebRequest -Uri "$base/25-PHASES-WAVE2-WAVE3.md" -OutFile ".\docs\25-PHASES-WAVE2-WAVE3.md" -Headers @{ "Cache-Control" = "no-cache" }
Write-Host "SUCCESS - Open docs\26-PRODUCT-BACKLOG-PHASES.md" -ForegroundColor Green
