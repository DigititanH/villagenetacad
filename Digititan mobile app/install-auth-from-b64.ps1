# Paste-run installer for Digititan auth slice
# Run inside: S:\WORK\Digititan mobile app
$ErrorActionPreference = "Stop"
if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Run this from S:\WORK\Digititan mobile app (must contain mobile\pubspec.yaml)"
}

$b64 = Get-Content -Raw -Path ".\auth-lib.b64"
$zipPath = Join-Path $PWD "auth-lib.zip"
$libPath = Join-Path $PWD "mobile\lib"
[IO.File]::WriteAllBytes($zipPath, [Convert]::FromBase64String($b64))

# Backup old main.dart once
$main = Join-Path $libPath "main.dart"
if (Test-Path $main) {
  Copy-Item $main (Join-Path $libPath "main.dart.bak") -Force
}

Expand-Archive -Path $zipPath -DestinationPath $libPath -Force
Remove-Item $zipPath -Force
Write-Host "Installed auth slice into mobile\lib"
Write-Host "Next: cd mobile; flutter run -d emulator-5554"
