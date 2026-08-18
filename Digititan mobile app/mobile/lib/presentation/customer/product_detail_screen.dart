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
