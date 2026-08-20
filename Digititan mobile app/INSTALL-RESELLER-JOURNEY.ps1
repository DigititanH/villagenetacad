# Sync FULL mobile/lib from GitHub so laptop matches cloud (fixes partial-sync compile errors).
# Run from: S:\WORK\Digititan mobile app
$ErrorActionPreference = "Stop"
if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. cd to S:\WORK\Digititan mobile app then rerun."
}
$base = "https://raw.githubusercontent.com/DigititanH/villagenetacad/cursor/reseller-apply-client-pipeline-09ad/Digititan%20mobile%20app"
$files = @(
  "mobile/lib/app/app.dart",
  "mobile/lib/app/injection.dart",
  "mobile/lib/application/academy/get_academies.dart",
  "mobile/lib/application/academy/register_academy_interest.dart",
  "mobile/lib/application/academy/register_academy_organisation.dart",
  "mobile/lib/application/auth/register_with_email.dart",
  "mobile/lib/application/auth/sign_in_with_email.dart",
  "mobile/lib/application/auth/sign_in_with_google.dart",
  "mobile/lib/application/auth/verify_email_otp.dart",
  "mobile/lib/application/store/get_my_orders.dart",
  "mobile/lib/application/store/get_products.dart",
  "mobile/lib/application/store/place_order.dart",
  "mobile/lib/application/training/get_programmes.dart",
  "mobile/lib/application/training/get_training_offers.dart",
  "mobile/lib/application/training/register_training_interest.dart",
  "mobile/lib/domain/entities/academy.dart",
  "mobile/lib/domain/entities/product.dart",
  "mobile/lib/domain/entities/programme_highlight.dart",
  "mobile/lib/domain/entities/reseller.dart",
  "mobile/lib/domain/entities/shop_order.dart",
  "mobile/lib/domain/entities/training_offer.dart",
  "mobile/lib/domain/entities/user.dart",
  "mobile/lib/domain/enums/user_role.dart",
  "mobile/lib/domain/repositories/academy_repository.dart",
  "mobile/lib/domain/repositories/admin_repository.dart",
  "mobile/lib/domain/repositories/auth_repository.dart",
  "mobile/lib/domain/repositories/email_sender.dart",
  "mobile/lib/domain/repositories/reseller_repository.dart",
  "mobile/lib/domain/repositories/store_repository.dart",
  "mobile/lib/domain/repositories/training_repository.dart",
  "mobile/lib/infrastructure/dummy/demo_hub.dart",
  "mobile/lib/infrastructure/dummy/dummy_academy_repository.dart",
  "mobile/lib/infrastructure/dummy/dummy_admin_repository.dart",
  "mobile/lib/infrastructure/dummy/dummy_auth_repository.dart",
  "mobile/lib/infrastructure/dummy/dummy_reseller_repository.dart",
  "mobile/lib/infrastructure/dummy/dummy_store_repository.dart",
  "mobile/lib/infrastructure/dummy/dummy_training_repository.dart",
  "mobile/lib/infrastructure/email/console_email_sender.dart",
  "mobile/lib/main.dart",
  "mobile/lib/presentation/admin/admin_shell.dart",
  "mobile/lib/presentation/auth/login_screen.dart",
  "mobile/lib/presentation/auth/otp_screen.dart",
  "mobile/lib/presentation/auth/register_screen.dart",
  "mobile/lib/presentation/customer/academy_detail_screen.dart",
  "mobile/lib/presentation/customer/academy_register_screen.dart",
  "mobile/lib/presentation/customer/cart_screen.dart",
  "mobile/lib/presentation/customer/checkout_screen.dart",
  "mobile/lib/presentation/customer/customer_shell.dart",
  "mobile/lib/presentation/customer/my_orders_screen.dart",
  "mobile/lib/presentation/customer/order_detail_screen.dart",
  "mobile/lib/presentation/customer/organisation_register_screen.dart",
  "mobile/lib/presentation/customer/payment_otp_screen.dart",
  "mobile/lib/presentation/customer/product_detail_screen.dart",
  "mobile/lib/presentation/customer/register_interest_screen.dart",
  "mobile/lib/presentation/customer/tabs/academies_tab.dart",
  "mobile/lib/presentation/customer/tabs/home_tab.dart",
  "mobile/lib/presentation/customer/tabs/profile_tab.dart",
  "mobile/lib/presentation/customer/tabs/store_tab.dart",
  "mobile/lib/presentation/customer/tabs/training_tab.dart",
  "mobile/lib/presentation/customer/training_detail_screen.dart",
  "mobile/lib/presentation/customer/widgets/sa_province_paths.dart",
  "mobile/lib/presentation/customer/widgets/south_africa_academies_map.dart",
  "mobile/lib/presentation/home/home_placeholder_screen.dart",
  "mobile/lib/presentation/reseller/reseller_shell.dart",
  "mobile/lib/presentation/shell/role_router.dart",
  "mobile/lib/shared/config/app_config.dart",
  "mobile/lib/shared/result/result.dart",
  "mobile/lib/shared/theme/digititan_brand_header.dart",
  "mobile/lib/shared/theme/digititan_theme.dart",
  "mobile/lib/shared/utils/open_digititan_store.dart",
  "mobile/lib/shared/widgets/demo_banner.dart",
  "docs/18-RESELLER-CODES-AND-DUAL-ADMIN.md",
  "docs/19-LIVE-DEMO-RESELLER-ADMIN.md",
)
$ok = 0
foreach ($rel in $files) {
  $url = "$base/" + ($rel -replace " ", "%20")
  $dest = Join-Path (Get-Location) ($rel -replace "/", "\")
  $dir = Split-Path $dest -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  Write-Host "GET $rel"
  Invoke-WebRequest -Uri $url -OutFile $dest
  $ok++
}
Write-Host ""
Write-Host "SUCCESS - Synced $ok files (full lib + reseller docs)." -ForegroundColor Green
Write-Host '  cd "S:\WORK\Digititan mobile app\mobile"'
Write-Host "  flutter run"
