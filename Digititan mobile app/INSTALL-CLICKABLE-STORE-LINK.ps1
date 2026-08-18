# Make Digititan Store URL clickable (opens browser)
# Run from: S:\WORK\Digititan mobile app  (NOT from mobile\)
# ASCII-only script (safe for Notepad paste)
$ErrorActionPreference = "Stop"
if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. Run from S:\WORK\Digititan mobile app then rerun."
}

Write-Host "=== Digititan: clickable Store URL ===" -ForegroundColor Cyan

$helper = ".\mobile\lib\shared\utils\open_digititan_store.dart"
$storeTab = ".\mobile\lib\presentation\customer\tabs\store_tab.dart"
$productDetail = ".\mobile\lib\presentation\customer\product_detail_screen.dart"
$config = ".\mobile\lib\shared\config\app_config.dart"

New-Item -ItemType Directory -Force -Path ".\mobile\lib\shared\utils" | Out-Null

# --- Dart helper ---
$helperDart = @'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_config.dart';

/// Opens Digititan Store in the system browser via our own MainActivity
/// MethodChannel (same drive as project - avoids url_launcher S: build bug).
const _browserChannel = MethodChannel('za.co.digititan.digititan_mobile/browser');

Future<bool> openDigititanStoreUrl() async {
  final url = AppConfig.digititanStoreUrl;
  try {
    final ok = await _browserChannel.invokeMethod<bool>('openUrl', {'url': url});
    return ok == true;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}

Future<void> openDigititanStore(BuildContext context) async {
  final url = AppConfig.digititanStoreUrl;
  final opened = await openDigititanStoreUrl();
  if (!context.mounted) return;

  if (opened) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Digititan Store website...')),
    );
    return;
  }

  await Clipboard.setData(ClipboardData(text: url));
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Digititan Store website'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tap the blue link to open the store:'),
          SizedBox(height: 12),
          DigititanStoreLink(),
          SizedBox(height: 12),
          Text(
            'Link also copied to clipboard if the browser does not open.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class DigititanStoreLink extends StatelessWidget {
  const DigititanStoreLink({super.key});

  @override
  Widget build(BuildContext context) {
    final url = AppConfig.digititanStoreUrl;
    return InkWell(
      onTap: () async {
        final ok = await openDigititanStoreUrl();
        if (!ok) {
          await Clipboard.setData(ClipboardData(text: url));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied: $url')),
            );
          }
        }
      },
      child: Text(
        url,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.blue.shade800,
              decoration: TextDecoration.underline,
              decorationColor: Colors.blue.shade800,
            ),
      ),
    );
  }
}
'@
[System.IO.File]::WriteAllText((Join-Path (Get-Location) $helper.TrimStart(".\")), $helperDart)
Write-Host "[1/4] Wrote open_digititan_store.dart"

# --- app_config message ---
if (Test-Path $config) {
  $cfg = Get-Content $config -Raw
  $cfg = $cfg -replace "(?s)static const storeModeMessage\s*=\s*'[^']*'\s*('[^']*')?\s*;", @"
static const storeModeMessage =
      'Sample products only. Full shopping is on the Digititan Store website. '
      'Tap the blue link or the button to open it.';
"@
  # Safer: rewrite known block if regex fragile - just ensure URL is correct
  if ($cfg -notmatch "www\.shop\.digititan\.co\.za") {
    Write-Host "WARNING: store URL missing in app_config - run INSTALL-STORE-URL first" -ForegroundColor Yellow
  }
  $cfgDart = @'
/// App-level constants (no secrets here).
class AppConfig {
  /// Official Digititan Store website for full shopping.
  static const digititanStoreUrl = 'https://www.shop.digititan.co.za/';

  /// Prototype notice shown in Store tab.
  static const storeModeMessage =
      'Sample products only. Full shopping is on the Digititan Store website. '
      'Tap the blue link or the button to open it.';

  static const emailOtpDemo = '123456';
  static const paymentOtpDemo = '654321';

  static const demoModeLine =
      'PROTOTYPE DEMO - dummy data. Branding later. Website + mobile = one ecosystem.';
}
'@
  [System.IO.File]::WriteAllText((Join-Path (Get-Location) $config.TrimStart(".\")), $cfgDart)
  Write-Host "[2/4] Updated app_config.dart"
}

# --- store_tab: ensure DigititanStoreLink is shown ---
# Full rewrite of store banner section is complex; rewrite whole store_tab from known good copy if file exists
$storeTabDart = Get-Content $storeTab -Raw -ErrorAction SilentlyContinue
if ($null -eq $storeTabDart) { Write-Error "Missing store_tab.dart" }

if ($storeTabDart -notmatch "DigititanStoreLink") {
  $storeTabDart = $storeTabDart -replace "label: const Text\('Copy Digititan Store website link'\),", "label: const Text('Open Digititan Store website'),"
  $storeTabDart = $storeTabDart -replace "icon: const Icon\(Icons\.link\),", "icon: const Icon(Icons.open_in_browser),"
  $storeTabDart = $storeTabDart -replace "(Text\(\s*AppConfig\.storeModeMessage,[\s\S]*?\),)", @"
Text(
                              AppConfig.storeModeMessage,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            const DigititanStoreLink(),
"@
  [System.IO.File]::WriteAllText((Join-Path (Get-Location) $storeTab.TrimStart(".\")), $storeTabDart)
}
Write-Host "[3/4] store_tab.dart checked"

# --- MainActivity MethodChannel ---
$main = Get-ChildItem -Path ".\mobile\android" -Recurse -Filter "MainActivity.kt" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $main) {
  Write-Error "MainActivity.kt not found under mobile\android. Is this a Flutter Android project?"
}

$mainKotlin = @'
package za.co.digititan.digititan_mobile

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val channelName = "za.co.digititan.digititan_mobile/browser"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
      .setMethodCallHandler { call, result ->
        if (call.method == "openUrl") {
          val url = call.argument<String>("url")
          if (url.isNullOrBlank()) {
            result.error("INVALID", "url is null", null)
            return@setMethodCallHandler
          }
          try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            startActivity(intent)
            result.success(true)
          } catch (e: Exception) {
            result.error("UNAVAILABLE", e.message, null)
          }
        } else {
          result.notImplemented()
        }
      }
  }
}
'@
[System.IO.File]::WriteAllText($main.FullName, $mainKotlin)
Write-Host "[4/4] Patched MainActivity.kt -> $($main.FullName)"

# product detail button label
if (Test-Path $productDetail) {
  $pd = Get-Content $productDetail -Raw
  $pd = $pd -replace "Copy Digititan Store website link", "Open Digititan Store website"
  $pd = $pd -replace "Icons\.link", "Icons.open_in_browser"
  if ($pd -notmatch "DigititanStoreLink") {
    $pd = $pd -replace "(Leadership decision: full purchase happens on Digititan Store website\.',[\s\S]*?TextStyle\(fontSize: 12\),\s*\),)", @"
'Leadership decision: full purchase happens on Digititan Store website.',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      const DigititanStoreLink(),
"@
  }
  [System.IO.File]::WriteAllText((Join-Path (Get-Location) $productDetail.TrimStart(".\")), $pd)
}

Write-Host ""
Write-Host "SUCCESS - Store URL is now clickable (opens Android browser)." -ForegroundColor Green
Write-Host "Full restart required (MethodChannel is native):"
Write-Host '  cd "S:\WORK\Digititan mobile app\mobile"'
Write-Host "  flutter run -d emulator-5554"
Write-Host "(Hot restart alone is not enough after MainActivity change.)"
