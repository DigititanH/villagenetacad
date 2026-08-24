import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/user.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/utils/open_digititan_store.dart';
import '../../shared/widgets/demo_banner.dart';
import '../../shared/widgets/product_price_text.dart';
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
    final p = _product;
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : p == null
              ? const Center(child: Text('Product not found'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                  children: [
                    Text(p.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(p.category, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 10),
                    ProductPriceText(
                      product: p,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (p.onPromotion && p.showsSalePrice) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'On promotion',
                        style: TextStyle(
                          color: DigititanColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(p.summary, style: const TextStyle(height: 1.4)),
                    const SizedBox(height: 18),
                    QuietNotice(
                      message:
                          'Full purchase happens on the Digititan Store website.',
                    ),
                    const SizedBox(height: 10),
                    const DigititanStoreLink(),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => openDigititanStore(context),
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Open Digititan Store'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: !p.inStock
                          ? null
                          : () {
                              widget.container.storeRepository.addToCart(p);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to demo cart')),
                              );
                            },
                      child: const Text('Add to demo cart'),
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
                      child: const Text('View demo cart'),
                    ),
                  ],
                ),
    );
  }
}
