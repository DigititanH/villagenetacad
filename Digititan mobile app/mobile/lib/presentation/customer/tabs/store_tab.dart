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
          // Sample only: best sellers / promos first, then the rest (max 4).
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
