import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/user.dart';
import '../../shared/config/app_config.dart';
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
                    Text(
                      'Purchase terms',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppConfig.purchaseTermsShort,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppConfig.pinnacleWarrantyNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 18),
                    QuietNotice(
                      message: AppConfig.useLiveApi
                          ? AppConfig.storeLiveCartMessage
                          : AppConfig.storeModeMessage,
                    ),
                    const SizedBox(height: 10),
                    const VillageNetAcadShopLink(),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => openVillageNetAcadShop(context),
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Open Village NetAcad shop'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: !p.inStock
                          ? null
                          : () async {
                              try {
                                await widget.container.storeRepository
                                    .addToCart(p);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppConfig.useLiveApi
                                          ? 'Added to shared cart'
                                          : 'Added to demo cart',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$e')),
                                );
                              }
                            },
                      child: Text(
                        AppConfig.useLiveApi
                            ? 'Add to shared cart'
                            : 'Add to demo cart',
                      ),
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
                      child: Text(
                        AppConfig.useLiveApi
                            ? 'View shared cart'
                            : 'View demo cart',
                      ),
                    ),
                  ],
                ),
    );
  }
}
