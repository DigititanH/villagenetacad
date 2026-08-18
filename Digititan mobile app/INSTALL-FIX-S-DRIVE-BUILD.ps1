# FIX: S: drive + url_launcher Kotlin incremental cache failure
# IMPORTANT: run from S:\WORK\Digititan mobile app  (NOT from mobile\)
$ErrorActionPreference = "Stop"
if (-not (Test-Path ".\mobile\pubspec.yaml")) {
  Write-Error "Wrong folder. Run: cd `"S:\WORK\Digititan mobile app`" then rerun this script."
}

Write-Host ""
Write-Host "=== Digititan: fix S-drive assembleDebug (url_launcher) ===" -ForegroundColor Cyan
Write-Host "Cause: project on S: , Pub Cache on C: -> Kotlin cannot relativize paths."
Write-Host "Fix: remove url_launcher; use clipboard+dialog; disable kotlin incremental."
Write-Host ""

$root = Resolve-Path "."
$mobile = Join-Path $root "mobile"
$androidDir = Join-Path $mobile "android"
$gradleProps = Join-Path $androidDir "gradle.properties"
$utilsDir = Join-Path $mobile "lib\shared\utils"
$storeTab = Join-Path $mobile "lib\presentation\customer\tabs\store_tab.dart"
$productDetail = Join-Path $mobile "lib\presentation\customer\product_detail_screen.dart"
$helper = Join-Path $utilsDir "open_digititan_store.dart"
$pubspec = Join-Path $mobile "pubspec.yaml"

New-Item -ItemType Directory -Force -Path $utilsDir | Out-Null
New-Item -ItemType Directory -Force -Path $androidDir | Out-Null

# --- 1) gradle.properties ---
Write-Host "[1/5] Writing android/gradle.properties (kotlin.incremental=false)..."
$existing = ""
if (Test-Path $gradleProps) {
  $existing = Get-Content $gradleProps -Raw
}
if ($existing -notmatch "kotlin\.incremental\s*=") {
  if ($existing.Length -gt 0 -and -not $existing.EndsWith("`n")) {
    $existing += "`r`n"
  }
  $existing += "kotlin.incremental=false`r`n"
  Set-Content -Path $gradleProps -Value $existing -NoNewline
} else {
  $existing = $existing -replace "kotlin\.incremental\s*=\s*\w+", "kotlin.incremental=false"
  Set-Content -Path $gradleProps -Value $existing -NoNewline
}

# --- 2) helper ---
Write-Host "[2/5] Writing open_digititan_store.dart (clipboard + dialog)..."
@'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_config.dart';

/// Opens the Digititan Store without a native plugin.
///
/// Why: `url_launcher` compiles Kotlin from Pub Cache on `C:` while this
/// project lives on `S:`. Kotlin incremental caches cannot relativize paths
/// across different drive roots, which breaks `assembleDebug`.
///
/// Prototype approach: copy the URL and show it so the user can open a browser.
Future<void> openDigititanStore(BuildContext context) async {
  final url = AppConfig.digititanStoreUrl;
  await Clipboard.setData(ClipboardData(text: url));
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Digititan Store website'),
      content: Text(
        'Store link copied to clipboard:\n\n$url\n\n'
        'Paste it into Chrome (or any browser) on this device.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
'@ | Set-Content -Path $helper -Encoding UTF8

# --- 3) store_tab.dart ---
Write-Host "[3/5] Updating store_tab.dart (no url_launcher)..."
@'
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
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () => openDigititanStore(context),
                              icon: const Icon(Icons.open_in_browser),
                              label: const Text('Shop on Digititan Store website'),
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
'@ | Set-Content -Path $storeTab -Encoding UTF8

# --- 4) product_detail_screen.dart ---
Write-Host "[4/5] Updating product_detail_screen.dart (no url_launcher)..."
@'
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
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => openDigititanStore(context),
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Buy on Digititan Store website'),
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
'@ | Set-Content -Path $productDetail -Encoding UTF8

# --- 5) remove url_launcher + clean ---
Write-Host "[5/5] Removing url_launcher and cleaning build caches..."
Push-Location $mobile
try {
  # Strip dependency lines if present (do not call flutter pub remove after strip —
  # PowerShell Stop mode treats "was not found" as a terminating NativeCommandError)
  $stillListed = $false
  if (Test-Path $pubspec) {
    $pub = Get-Content $pubspec -Raw
    $pub2 = $pub -replace "(?m)^\s*url_launcher\s*:.*\r?\n", ""
    if ($pub2 -ne $pub) {
      Set-Content -Path $pubspec -Value $pub2 -NoNewline
      Write-Host "  Removed url_launcher from pubspec.yaml"
    }
    $stillListed = Select-String -Path $pubspec -Pattern "url_launcher" -Quiet
  }

  if ($stillListed) {
    Write-Host "  flutter pub remove url_launcher..."
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    flutter pub remove url_launcher 2>&1 | Out-Host
    $ErrorActionPreference = $prevEap
  } else {
    Write-Host "  url_launcher already absent from pubspec — skip pub remove"
  }

  Write-Host "  flutter clean..."
  flutter clean | Out-Host

  $buildDir = Join-Path $mobile "build"
  if (Test-Path $buildDir) {
    Remove-Item -Recurse -Force $buildDir -ErrorAction SilentlyContinue
    Write-Host "  Deleted mobile\build"
  }

  Write-Host "  flutter pub get..."
  flutter pub get | Out-Host
}
finally {
  Pop-Location
}

# Verify
$ok = $true
if (-not (Test-Path $helper)) { Write-Host "MISSING helper" -ForegroundColor Red; $ok = $false }
if (-not (Select-String -Path $storeTab -Pattern "openDigititanStore" -Quiet)) {
  Write-Host "store_tab missing openDigititanStore" -ForegroundColor Red; $ok = $false
}
if (Select-String -Path $storeTab -Pattern "url_launcher" -Quiet) {
  Write-Host "store_tab still imports url_launcher" -ForegroundColor Red; $ok = $false
}
if (Select-String -Path $productDetail -Pattern "url_launcher" -Quiet) {
  Write-Host "product_detail still imports url_launcher" -ForegroundColor Red; $ok = $false
}
if (-not (Select-String -Path $gradleProps -Pattern "kotlin.incremental=false" -Quiet)) {
  Write-Host "gradle.properties missing kotlin.incremental=false" -ForegroundColor Red; $ok = $false
}
if (Test-Path $pubspec) {
  if (Select-String -Path $pubspec -Pattern "url_launcher" -Quiet) {
    Write-Host "WARNING: url_launcher still listed in pubspec.yaml" -ForegroundColor Yellow
  }
}

Write-Host ""
if ($ok) {
  Write-Host "SUCCESS — S-drive build fix applied." -ForegroundColor Green
  Write-Host ""
  Write-Host "Next:"
  Write-Host '  cd "S:\WORK\Digititan mobile app\mobile"'
  Write-Host "  flutter run -d emulator-5554"
  Write-Host ""
  Write-Host "Store button behavior now: copies https://digititan.co.za and shows a dialog."
} else {
  Write-Host "FAILED — verify files above and rerun from parent folder." -ForegroundColor Red
  exit 1
}
