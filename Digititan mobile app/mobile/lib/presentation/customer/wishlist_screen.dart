import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/store_repository.dart';
import '../../shared/config/app_config.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/utils/friendly_api_error.dart';
import '../../shared/widgets/product_image.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  final AppContainer container;
  final User user;

  const WishlistScreen({
    super.key,
    required this.container,
    required this.user,
  });

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _loading = true;
  String? _error;
  List<WishlistItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await widget.container.storeRepository.getWishlist();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = friendlyApiError(e);
      });
    }
  }

  Future<void> _remove(WishlistItem item) async {
    try {
      await widget.container.storeRepository.toggleWishlist(item.productId);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyApiError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Text(
                        AppConfig.useLiveApi
                            ? 'Wishlist is empty. Heart a product to save it.'
                            : 'Wishlist is empty (demo).',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final item = _items[i];
                        return Material(
                          color: DigititanColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          child: ListTile(
                            leading: ProductImage(
                              imageUrl: item.imageUrl,
                              size: 48,
                            ),
                            title: Text(item.name),
                            subtitle: Text('R${item.price.toStringAsFixed(0)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () => _remove(item),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    container: widget.container,
                                    user: widget.user,
                                    productId: item.productId,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
