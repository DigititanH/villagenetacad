# Fix blank Resellers tab — pull ONLY the 2 fixed files (no zip, no file list).
# Run from: S:\WORK\Digititan mobile app
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\Digititan mobile app"
}

# Pin to commit so GitHub CDN cannot serve stale files
$sha = "32712b252e0dfbc96a55fe674c1a10df0e9f27d5"
$base = "https://raw.githubusercontent.com/DigititanH/villagenetacad/$sha/Digititan%20mobile%20app"

$pairs = @(
  @{ Rel = "mobile/lib/presentation/admin/admin_shell.dart"; Must = "trailing: TextButton" },
  @{ Rel = "mobile/lib/shared/theme/digititan_theme.dart"; Must = "minimumSize: const Size(48, 48)" }
)

foreach ($p in $pairs) {
  $url = "$base/" + ($p.Rel -replace " ", "%20")
  $dest = Join-Path (Get-Location) ($p.Rel -replace "/", "\")
  Write-Host "GET $($p.Rel)"
  Invoke-WebRequest -Uri $url -OutFile $dest -Headers @{ "Cache-Control" = "no-cache" }
  $hit = Select-String -Path $dest -Pattern $p.Must -SimpleMatch
  if ($null -eq $hit) {
    Write-Error "Downloaded file missing expected fix marker: $($p.Must)"
  }
}

Write-Host "SUCCESS - Resellers tab fix applied." -ForegroundColor Green
Write-Host "  cd mobile"
Write-Host "  flutter run"
Write-Host "Then: Ops Admin -> Resellers -> tap Approve on Sipho (or any pending row)."
Write-Host "Long-press a row to Reject."
