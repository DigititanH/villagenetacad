# PHASE 7 - PayFast ITN pack download (docs + deploy files)
# Run from: S:\WORK\VillageNetAcad  OR  Downloads
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$branch = "cursor/phase7-payfast-itn-09ad"
$bust = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$base = "https://cdn.jsdelivr.net/gh/DigititanH/villagenetacad@${branch}/deploy/phase7-itn-live"
$out = Join-Path (Get-Location) "phase7-itn-live"
if (-not (Test-Path $out)) { New-Item -ItemType Directory -Path $out | Out-Null }

Write-Host "Downloading Phase 7 ITN pack from DigititanH/${branch} ..." -ForegroundColor Cyan
foreach ($f in @("Payfast.php", "notify.php", "README.md")) {
  $url = "$base/${f}?t=${bust}"
  Write-Host "  $f"
  Invoke-WebRequest -Uri $url -OutFile (Join-Path $out $f) -Headers @{
    "Cache-Control" = "no-cache"
    "Pragma" = "no-cache"
  }
}

Write-Host ""
Write-Host "SUCCESS - files in: $out" -ForegroundColor Green
Write-Host ""
Write-Host "UPLOAD ONLY TO LIVE TREE:" -ForegroundColor Yellow
Write-Host "  1) Edit public_html/backend-php/.env"
Write-Host "       PAYFAST_NOTIFY_URL=https://villagenetacad.co.za/api/payfast/notify"
Write-Host "  2) Upload Payfast.php  -> public_html/backend-php/lib/Payfast.php"
Write-Host "  3) Upload notify.php   -> public_html/payfast/notify.php"
Write-Host "     (site-root /payfast/ - NOT backend-php/payfast/)"
Write-Host ""
Write-Host "DO NOT touch:" -ForegroundColor Red
Write-Host "  - public_html/village-netacad/backend-php/  (stale duplicate)"
Write-Host "  - public_html/backend-php/payfast/         (wrong stub folder)"
Write-Host "Smoke: https://villagenetacad.co.za/api/payfast/status"
Write-Host "Expect notify_url ending with /api/payfast/notify"
