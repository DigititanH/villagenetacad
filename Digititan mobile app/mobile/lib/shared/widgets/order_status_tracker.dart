import 'package:flutter/material.dart';

import '../../domain/entities/shop_order.dart';
import '../../shared/theme/digititan_theme.dart';

/// Visual pipeline for live order statuses (Phase 6).
class OrderStatusTracker extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusTracker({super.key, required this.status});

  static const _steps = <(OrderStatus, String)>[
    (OrderStatus.placed, 'Placed'),
    (OrderStatus.paid, 'Paid'),
    (OrderStatus.processing, 'Processing'),
    (OrderStatus.shipped, 'Shipped'),
    (OrderStatus.delivered, 'Delivered'),
  ];

  int get _activeIndex {
    if (status == OrderStatus.cancelled) return -1;
    if (status == OrderStatus.returnRequested) {
      return _steps.indexWhere((e) => e.$1 == OrderStatus.delivered);
    }
    final i = _steps.indexWhere((e) => e.$1 == status);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.cancel_outlined, color: DigititanColors.danger),
        title: Text('Order cancelled'),
      );
    }

    final active = _activeIndex;
    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              i <= active ? Icons.check_circle : Icons.radio_button_unchecked,
              color: i <= active
                  ? DigititanColors.teal
                  : DigititanColors.muted,
            ),
            title: Text(
              _steps[i].$2,
              style: TextStyle(
                fontWeight: i == active ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            subtitle: i < active
                ? const Text('Done')
                : (i == active ? const Text('Current') : const Text('Pending')),
          ),
        if (status == OrderStatus.returnRequested)
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.assignment_return_outlined),
            title: Text('Return requested'),
          ),
      ],
    );
  }
}
