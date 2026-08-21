# Set confirmed Digititan Store URL
# Run from: S:\WORK\Digititan mobile app  (NOT from mobile\)
$ErrorActionPreference = "Stop"
if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. Run from S:\WORK\Digititan mobile app then rerun this script."
}

$path = ".\mobile\lib\shared\config\app_config.dart"
if (-not (Test-Path $path)) {
  Write-Error "Missing app_config.dart - run earlier installers first."
}

$dart = @"
/// App-level constants (no secrets here).
class AppConfig {
  /// Official Digititan Store website for full shopping.
  static const digititanStoreUrl = 'https://www.shop.digititan.co.za/';

  /// Prototype notice shown in Store tab.
  static const storeModeMessage =
      'Sample products only. Full shopping is on the Digititan Store website '
      '(button copies the link - paste into Chrome).';

  static const emailOtpDemo = '123456';
  static const paymentOtpDemo = '654321';

  static const demoModeLine =
      'PROTOTYPE DEMO - dummy data. Branding later. Website + mobile = one ecosystem.';
}
"@

$full = Join-Path (Get-Location) "mobile\lib\shared\config\app_config.dart"
[System.IO.File]::WriteAllText($full, $dart)

$ok = Select-String -Path $path -Pattern "www\.shop\.digititan\.co\.za" -Quiet
Write-Host ""
if ($ok) {
  Write-Host "SUCCESS - Store URL set to https://www.shop.digititan.co.za/" -ForegroundColor Green
  Write-Host ""
  Write-Host "Hot restart the running app (press r in the flutter terminal),"
  Write-Host "or:"
  Write-Host '  cd "S:\WORK\Digititan mobile app\mobile"'
  Write-Host "  flutter run -d emulator-5554"
} else {
  Write-Host "FAILED - URL not found in app_config.dart" -ForegroundColor Red
  exit 1
}
