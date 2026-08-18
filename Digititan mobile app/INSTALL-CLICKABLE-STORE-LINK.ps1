# Make Digititan Store URL clickable (opens browser)
# Run from: S:\WORK\Digititan mobile app  (NOT from mobile\)
# ASCII-only (safe for Notepad paste)
$ErrorActionPreference = "Stop"
if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. Run from S:\WORK\Digititan mobile app then rerun."
}

Write-Host "=== Digititan: clickable Store URL ===" -ForegroundColor Cyan
$root = (Get-Location).Path

function Write-Utf8([string]$rel, [string]$content) {
  $full = Join-Path $root $rel
  $dir = Split-Path $full -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [System.IO.File]::WriteAllText($full, $content)
}

# 1) Dart helper
Write-Utf8 "mobile\lib\shared\utils\open_digititan_store.dart" @'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_config.dart';

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
Write-Host "[1/5] open_digititan_store.dart"

# 2) config
Write-Utf8 "mobile\lib\shared\config\app_config.dart" @'
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
Write-Host "[2/5] app_config.dart"

# 3) store_tab
Write-Utf8 "mobile\lib\presentation\customer\tabs\store_tab.dart" @'
import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/user.dart';
import '../../../shared/config/app_config.dart';
import '../../../shared/result/result.dart';
import '../../../shared/utils/open_digititan_store.dart';
import '../product_detail_screen.dart';

/// Leadership decision:
/// - Show sample products in-app
/// - Full shopping happens on Digititan Store website
class StoreTab extends StatefulWidget {
  final AppContainer container;
  final User user;

  const StoreTab({
    super.key,
    required this.container,
    required this.user,
  });

  @override
  State<StoreTab> createState() => _StoreTabState();
}

class _StoreTabState extends State<StoreTab> {
  List<Product> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.container.getProducts();
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Success(:final data):
          final featured = data.where((p) => p.isBestSeller || p.onPromotion).toList();
          final rest = data.where((p) => !p.isBestSeller && !p.onPromotion);
          _products = [...featured, ...rest].take(4).toList();
        case Failure(:final message):
          _error = message;
      }
    });
  }

  String _money(double v) => 'R${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppConfig.storeModeMessage,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            const DigititanStoreLink(),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () => openDigititanStore(context),
                              icon: const Icon(Icons.open_in_browser),
                              label: const Text('Open Digititan Store website'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Sample products', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ..._products.map(
                      (p) => Card(
                        child: ListTile(
                          title: Text(p.name),
                          subtitle: Text(
                            '${p.category} · ${_money(p.price)}'
                            '${p.isBestSeller ? ' · Best seller' : ''}'
                            '${p.onPromotion ? ' · Promo' : ''}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(
                                  container: widget.container,
                                  user: widget.user,
                                  productId: p.id,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: In-app cart/checkout remains available as prototype demo only.\n'
                      'Production shopping path = website.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
    );
  }
}
'@
Write-Host "[3/5] store_tab.dart"

# 4) product detail
Write-Utf8 "mobile\lib\presentation\customer\product_detail_screen.dart" @'
import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/user.dart';
import '../../shared/utils/open_digititan_store.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final AppContainer container;
  final User user;
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.container,
    required this.user,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final product = await widget.container.storeRepository.getProduct(widget.productId);
    if (!mounted) return;
    setState(() {
      _product = product;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product sample')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
              ? const Center(child: Text('Product not found'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(_product!.name, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text('${_product!.category} · R${_product!.price.toStringAsFixed(0)}'),
                      const SizedBox(height: 12),
                      Text(_product!.summary),
                      const SizedBox(height: 12),
                      const Text(
                        'Leadership decision: full purchase happens on Digititan Store website.',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      const DigititanStoreLink(),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => openDigititanStore(context),
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Open Digititan Store website'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: !_product!.inStock
                            ? null
                            : () {
                                widget.container.storeRepository.addToCart(_product!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to prototype demo cart (not production path)'),
                                  ),
                                );
                              },
                        child: const Text('Add to prototype demo cart'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CartScreen(
                                container: widget.container,
                                user: widget.user,
                              ),
                            ),
                          );
                        },
                        child: const Text('Open prototype demo cart'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
'@
Write-Host "[4/5] product_detail_screen.dart"

# 5) MainActivity MethodChannel (project-local Kotlin - safe on S:)
$main = Get-ChildItem -Path (Join-Path $root "mobile\android") -Recurse -Filter "MainActivity.kt" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $main) {
  Write-Error "MainActivity.kt not found under mobile\android"
}

$pkg = "za.co.digititan.digititan_mobile"
$first = Get-Content $main.FullName -TotalCount 5 | Out-String
if ($first -match 'package\s+([a-zA-Z0-9_.]+)') {
  $pkg = $Matches[1]
}

$kotlin = @"
package $pkg

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
"@
[System.IO.File]::WriteAllText($main.FullName, $kotlin)
Write-Host "[5/5] Patched MainActivity.kt ($($main.FullName))"

Write-Host ""
Write-Host "SUCCESS - Store link is blue/underlined and opens the browser." -ForegroundColor Green
Write-Host "Full restart required (native MainActivity changed):"
Write-Host '  cd "S:\WORK\Digititan mobile app\mobile"'
Write-Host "  flutter run -d emulator-5554"
