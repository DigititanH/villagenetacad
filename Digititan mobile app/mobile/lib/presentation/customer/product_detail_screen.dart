import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/user.dart';
import '../../infrastructure/api/http_store_repository.dart';
import '../../shared/config/app_config.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/utils/friendly_api_error.dart';
import '../../shared/utils/open_digititan_store.dart';
import '../../shared/widgets/demo_banner.dart';
import '../../shared/widgets/product_image.dart';
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
  bool _wishBusy = false;
  bool _wishlisted = false;
  int _qty = 1;
  String? _size;
  String? _color;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final product =
        await widget.container.storeRepository.getProduct(widget.productId);
    if (!mounted) return;
    setState(() {
      _product = product;
      _loading = false;
      if (product != null) {
        _size = product.sizes.isNotEmpty ? product.sizes.first : null;
        _color = product.colors.isNotEmpty ? product.colors.first : null;
      }
    });
    await _refreshWishlistFlag();
  }

  Future<void> _refreshWishlistFlag() async {
    final p = _product;
    if (p == null) return;
    try {
      final items = await widget.container.storeRepository.getWishlist();
      if (!mounted) return;
      setState(() {
        _wishlisted = items.any((w) => w.productId == p.id);
      });
    } catch (_) {
      // Ignore — heart still shows; toggle will surface errors.
    }
  }

  Future<void> _toggleWish() async {
    final p = _product;
    if (p == null) return;
    setState(() => _wishBusy = true);
    try {
      final on = await widget.container.storeRepository.toggleWishlist(p.id);
      if (!mounted) return;
      setState(() => _wishlisted = on);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(on ? 'Added to wishlist' : 'Removed from wishlist'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyApiError(e))),
      );
    } finally {
      if (mounted) setState(() => _wishBusy = false);
    }
  }

  Future<void> _addToCart() async {
    final p = _product;
    if (p == null) return;
    try {
      await widget.container.storeRepository.addToCart(
        p,
        quantity: _qty,
        size: _size,
        color: _color,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppConfig.useLiveApi ? 'Added to shared cart' : 'Added to demo cart',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyApiError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _product;
    final store = widget.container.storeRepository;
    final liveSample = store is HttpStoreRepository &&
        store.usingSampleCatalogue &&
        p != null &&
        !store.canAddToLiveCart(p);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        actions: [
          if (p != null)
            IconButton(
              tooltip: _wishlisted ? 'Remove from wishlist' : 'Add to wishlist',
              onPressed: _wishBusy ? null : _toggleWish,
              icon: Icon(
                _wishlisted ? Icons.favorite : Icons.favorite_border,
                color: _wishlisted ? Colors.red : null,
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : p == null
              ? const Center(child: Text('Product not found'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                  children: [
                    Center(
                      child: ProductImage(
                        imageUrl: p.imageUrl,
                        size: 220,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(p.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      [
                        p.category,
                        if (p.stockCount > 0) '${p.stockCount} in stock',
                        if (!p.inStock) 'Out of stock',
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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
                    if (p.sizes.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text('Size', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: p.sizes
                            .map(
                              (s) => ChoiceChip(
                                label: Text(s),
                                selected: _size == s,
                                onSelected: (_) => setState(() => _size = s),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    if (p.colors.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text('Colour', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: p.colors
                            .map(
                              (c) => ChoiceChip(
                                label: Text(c),
                                selected: _color == c,
                                onSelected: (_) => setState(() => _color = c),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Text('Quantity', style: Theme.of(context).textTheme.titleSmall),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _qty <= 1
                              ? null
                              : () => setState(() => _qty -= 1),
                          icon: const Icon(Icons.remove),
                        ),
                        Text('$_qty', style: Theme.of(context).textTheme.titleMedium),
                        IconButton(
                          onPressed: () => setState(() => _qty += 1),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                      message: liveSample
                          ? AppConfig.storeLiveEmptyCatalogueMessage
                          : (AppConfig.useLiveApi
                              ? AppConfig.storeLiveCartMessage
                              : AppConfig.storeModeMessage),
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
                      onPressed: !p.inStock ? null : _addToCart,
                      child: Text(
                        AppConfig.useLiveApi
                            ? (liveSample
                                ? 'Add to walkthrough cart'
                                : 'Add to shared cart')
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
                            ? (liveSample
                                ? 'View walkthrough cart'
                                : 'View shared cart')
                            : 'View demo cart',
                      ),
                    ),
                  ],
                ),
    );
  }
}
