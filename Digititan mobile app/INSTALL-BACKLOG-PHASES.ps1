# Sync product backlog docs to S:\WORK\VillageNetAcad
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\VillageNetAcad"
}

$branch = "cursor/wave1-meeting-feedback-09ad"
$base = "https://raw.githubusercontent.com/DigititanH/villagenetacad/$branch/Digititan%20mobile%20app/docs"
$docs = Join-Path (Get-Location) "docs"
if (-not (Test-Path $docs)) { New-Item -ItemType Directory -Path $docs | Out-Null }

@(
  "26-PRODUCT-BACKLOG-PHASES.md",
  "25-PHASES-WAVE2-WAVE3.md",
  "22-WAVE1-MEETING-FEEDBACK.md"
) | ForEach-Object {
  $url = "$base/$_"
  $out = Join-Path $docs $_
  Write-Host "Downloading $_ ..."
  Invoke-WebRequest -Uri $url -OutFile $out -Headers @{ "Cache-Control" = "no-cache" }
}

$hit = Select-String -Path (Join-Path $docs "26-PRODUCT-BACKLOG-PHASES.md") -Pattern "Launch gate" -SimpleMatch
if ($null -eq $hit) { Write-Error "Download failed" }

Write-Host "SUCCESS - open docs\26-PRODUCT-BACKLOG-PHASES.md" -ForegroundColor Green
Write-Host "Waves 2+3 are inside Phases 2-12. Next build: Phase 2 (QR verify first)."
