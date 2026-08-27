# Pull phase docs onto laptop (Wave 2 / Wave 3 roadmap)
# Run from: S:\WORK\VillageNetAcad
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\VillageNetAcad"
}

$base = "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/wave1-meeting-feedback-09ad/Digititan%20mobile%20app/docs"
$docs = Join-Path (Get-Location) "docs"
if (-not (Test-Path $docs)) { New-Item -ItemType Directory -Path $docs | Out-Null }

$files = @(
  "12-LOCKED-DECISIONS.md",
  "22-WAVE1-MEETING-FEEDBACK.md",
  "25-PHASES-WAVE2-WAVE3.md"
)

foreach ($f in $files) {
  $url = "$base/$f"
  $dest = Join-Path $docs $f
  Write-Host "Downloading $f ..."
  Invoke-WebRequest -Uri $url -OutFile $dest -Headers @{ "Cache-Control" = "no-cache" }
}

$hit = Select-String -Path (Join-Path $docs "25-PHASES-WAVE2-WAVE3.md") -Pattern "Wave 2A" -SimpleMatch
if ($null -eq $hit) { Write-Error "Download failed - 25-PHASES-WAVE2-WAVE3.md incomplete" }

Write-Host "SUCCESS - Phase roadmap on laptop." -ForegroundColor Green
Write-Host "  Open: docs\25-PHASES-WAVE2-WAVE3.md"
Write-Host "  Next build: Wave 2A (QR + verify reseller)"
