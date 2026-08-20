$ErrorActionPreference = "Stop"
if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\Digititan mobile app then rerun."
}
$base = "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/reseller-apply-client-pipeline-09ad/Digititan%20mobile%20app"
$files = @(
  "mobile/lib/app/injection.dart",
  "mobile/lib/application/auth/register_with_email.dart",
  "mobile/lib/domain/entities/reseller.dart",
  "mobile/lib/domain/repositories/reseller_repository.dart",
  "mobile/lib/infrastructure/dummy/demo_hub.dart",
  "mobile/lib/infrastructure/dummy/dummy_admin_repository.dart",
  "mobile/lib/infrastructure/dummy/dummy_reseller_repository.dart",
  "mobile/lib/infrastructure/dummy/dummy_store_repository.dart",
  "mobile/lib/presentation/auth/login_screen.dart",
  "mobile/lib/presentation/auth/register_screen.dart",
  "mobile/lib/presentation/reseller/reseller_shell.dart",
  "mobile/lib/presentation/customer/checkout_screen.dart",
  "mobile/lib/presentation/admin/admin_shell.dart",
  "mobile/lib/domain/enums/user_role.dart",
  "mobile/lib/infrastructure/dummy/dummy_auth_repository.dart",
  "docs/18-RESELLER-CODES-AND-DUAL-ADMIN.md",
  "docs/19-LIVE-DEMO-RESELLER-ADMIN.md",
)
foreach ($rel in $files) {
  $url = "$base/" + ($rel -replace " ", "%20")
  $dest = Join-Path (Get-Location) ($rel -replace "/", "\")
  $dir = Split-Path $dest -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  Write-Host "GET $rel"
  Invoke-WebRequest -Uri $url -OutFile $dest
}
Write-Host ""
Write-Host "SUCCESS - Reseller journey files synced." -ForegroundColor Green
Write-Host "Open docs\19-LIVE-DEMO-RESELLER-ADMIN.md for the click-path."
Write-Host '  cd "S:\WORK\Digititan mobile app\mobile"'
Write-Host "  flutter run"
