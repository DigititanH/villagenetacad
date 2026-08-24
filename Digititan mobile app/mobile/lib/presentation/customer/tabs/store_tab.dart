import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/user.dart';
import '../../../shared/config/app_config.dart';
import '../../../shared/result/result.dart';
import '../../../shared/theme/digititan_theme.dart';
import '../../../shared/utils/open_digititan_store.dart';
import '../../../shared/widgets/demo_banner.dart';
import '../../../shared/widgets/product_price_text.dart';
import '../product_detail_screen.dart';

/// Leadership decision (Phase 3):
/// - Show sample products in-app
/// - Full shopping happens on the Village NetAcad shop website
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
          final featured =
              data.where((p) => p.isBestSeller || p.onPromotion).toList();
          final rest = data.where((p) => !p.isBestSeller && !p.onPromotion);
          _products = [...featured, ...rest];
        case Failure(:final message):
          _error = message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    QuietNotice(message: AppConfig.storeModeMessage),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => openVillageNetAcadShop(context),
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Open Village NetAcad shop'),
                    ),
                    const SizedBox(height: 4),
                    const VillageNetAcadShopLink(),
                    const SizedBox(height: 8),
                    const SectionHeader(title: 'Sample catalogue'),
                    ..._products.map(_productTile),
                  ],
                ),
    );
  }

  Widget _productTile(Product p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: DigititanColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
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
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: DigititanColors.muted),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          p.category,
                          if (p.isBestSeller) 'Best seller',
                          if (p.onPromotion) 'Promo',
                        ].join(' · '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      ProductPriceText(product: p, compact: true),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: DigititanColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
