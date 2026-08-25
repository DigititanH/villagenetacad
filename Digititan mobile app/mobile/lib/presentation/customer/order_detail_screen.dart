import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/shop_order.dart';
import '../../shared/config/app_config.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/widgets/order_status_tracker.dart';
import 'return_request_screen.dart';
import 'review_order_screen.dart';

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
                    if (widget.justPlaced) ...[
                      const Text(
                        'Sale confirmed (PayFast story + OTP).',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (_order!.referralCode != null)
                        Text(
                          'Attributed to reseller code ${_order!.referralCode} '
                          '(split: Beneficiary 53% · Centre 26% · Digititan/VNA 21%).',
                        )
                      else
                        const Text('No reseller code on this order.'),
                      const SizedBox(height: 8),
                    ],
                    Text(_order!.id, style: Theme.of(context).textTheme.titleLarge),
                    Text('Status: ${_order!.status.name}'),
                    Text('Total: R${_order!.total.toStringAsFixed(0)}'),
                    if (_order!.deliveredAt != null)
                      Text(
                        'Delivered: ${_order!.deliveredAt!.toIso8601String().substring(0, 10)}',
                      ),
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
                    Text('Status', style: Theme.of(context).textTheme.titleMedium),
                    OrderStatusTracker(status: _order!.status),
                    const SizedBox(height: 8),
                    Text('Tracking detail', style: Theme.of(context).textTheme.titleMedium),
                    ..._order!.trackingTimeline.map(
                      (t) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(t),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConfig.pinnacleWarrantyNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    if (_order!.canRequestReturn)
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReturnRequestScreen(
                                container: widget.container,
                                order: _order!,
                              ),
                            ),
                          );
                          await _load();
                        },
                        icon: const Icon(Icons.assignment_return),
                        label: Text(
                          'Request return (${_order!.returnDaysLeft} days left)',
                        ),
                      )
                    else if (_order!.returnRequested)
                      const Text(
                        'Return already requested for this order.',
                        style: TextStyle(
                          color: DigititanColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (_order!.status == OrderStatus.delivered)
                      Text(
                        'Return window closed (${AppConfig.returnWindowDays} days after delivery).',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 8),
                    if (_order!.canReview)
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReviewOrderScreen(
                                container: widget.container,
                                order: _order!,
                              ),
                            ),
                          );
                          await _load();
                        },
                        icon: const Icon(Icons.star_outline),
                        label: const Text('Leave a review'),
                      )
                    else if (_order!.reviewed)
                      Text(
                        'You reviewed this order'
                        '${_order!.reviewStars == null ? '' : ' (${_order!.reviewStars}★)'}.',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
    );
  }
}
