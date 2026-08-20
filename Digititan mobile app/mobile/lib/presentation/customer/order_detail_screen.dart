import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/shop_order.dart';

class OrderDetailScreen extends StatefulWidget {
  final AppContainer container;
  final String orderId;
  final bool justPlaced;

  const OrderDetailScreen({
    super.key,
    required this.container,
    required this.orderId,
    this.justPlaced = false,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  ShopOrder? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final order = await widget.container.storeRepository.getOrder(widget.orderId);
    if (!mounted) return;
    setState(() {
      _order = order;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.justPlaced ? 'Order success' : 'Order tracking'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Order not found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (widget.justPlaced)
                      const Text('Payment confirmed (prototype).'),
                    const SizedBox(height: 8),
                    Text(_order!.id, style: Theme.of(context).textTheme.titleLarge),
                    Text('Status: ${_order!.status.name}'),
                    Text('Total: R${_order!.total.toStringAsFixed(0)}'),
                    const SizedBox(height: 16),
                    Text('Items', style: Theme.of(context).textTheme.titleMedium),
                    ..._order!.items.map(
                      (i) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(i.productName),
                        subtitle: Text(
                          '${i.quantity} × R${i.unitPrice.toStringAsFixed(0)}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Tracking', style: Theme.of(context).textTheme.titleMedium),
                    ..._order!.trackingTimeline.map(
                      (t) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(t),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Returns / reviews come in a later polish pass.\n'
                      'Warranty note: follow Pinnacle policy (from meeting).',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
    );
  }
}
