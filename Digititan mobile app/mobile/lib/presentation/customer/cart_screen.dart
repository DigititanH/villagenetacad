import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/store_repository.dart';
import '../../shared/config/app_config.dart';
import '../../shared/utils/friendly_api_error.dart';
import '../../shared/utils/open_digititan_store.dart';
import '../../shared/widgets/product_image.dart';
import '../../shared/widgets/product_price_text.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final AppContainer container;
  final User user;

  const CartScreen({
    super.key,
    required this.container,
    required this.user,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _loading = true;
  String? _error;
  List<CartLine> _lines = const [];
  double _total = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final store = widget.container.storeRepository;
      final lines = await store.getCart();
      final total = await store.cartTotal();
      if (!mounted) return;
      setState(() {
        _lines = lines;
        _total = total;
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

  Future<void> _setQty(CartLine line, int qty) async {
    setState(() => _busy = true);
    try {
      await widget.container.storeRepository.updateQuantity(line, qty);
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyApiError(e))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkout() async {
    final store = widget.container.storeRepository;
    if (store.checkoutOnWebsite) {
      final ok = await openVillageNetAcadCart(context);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Complete payment on the website. Orders will show under My orders.',
            ),
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          container: widget.container,
          user: widget.user,
        ),
      ),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConfig.useLiveApi ? 'Cart (shared)' : 'Cart',
        ),
        actions: [
          IconButton(
            onPressed: _busy ? null : _reload,
            icon: const Icon(Icons.refresh),
          ),
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
              : _lines.isEmpty
                  ? const Center(child: Text('Cart is empty'))
                  : Column(
                      children: [
                        if (AppConfig.useLiveApi)
                          const Material(
                            color: Color(0xFFE8F0FE),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'This cart is shared with villagenetacad.co.za. '
                                'Checkout opens the website for PayFast.',
                                style: TextStyle(fontSize: 13, height: 1.35),
                              ),
                            ),
                          ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _lines.length,
                            itemBuilder: (context, i) {
                              final line = _lines[i];
                              return ListTile(
                                leading: ProductImage(
                                  imageUrl: line.product.imageUrl,
                                  size: 48,
                                ),
                                title: Text(line.product.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ProductPriceText(
                                      product: line.product,
                                      compact: true,
                                    ),
                                    if ((line.size ?? '').isNotEmpty ||
                                        (line.color ?? '').isNotEmpty)
                                      Text(
                                        [
                                          if ((line.size ?? '').isNotEmpty)
                                            'Size ${line.size}',
                                          if ((line.color ?? '').isNotEmpty)
                                            line.color!,
                                        ].join(' · '),
                                      ),
                                    Text(
                                      '× ${line.quantity} = R${line.lineTotal.toStringAsFixed(0)}',
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: _busy
                                          ? null
                                          : () =>
                                              _setQty(line, line.quantity - 1),
                                      icon: const Icon(Icons.remove),
                                    ),
                                    Text('${line.quantity}'),
                                    IconButton(
                                      onPressed: _busy
                                          ? null
                                          : () =>
                                              _setQty(line, line.quantity + 1),
                                      icon: const Icon(Icons.add),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Total: R${_total.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _busy ? null : _checkout,
                                child: Text(
                                  storeCheckoutLabel(
                                    widget.container.storeRepository,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}

String storeCheckoutLabel(StoreRepository store) => store.checkoutOnWebsite
    ? 'Complete on website (PayFast)'
    : 'Checkout';
