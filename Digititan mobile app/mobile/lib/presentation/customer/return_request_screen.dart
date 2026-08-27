import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/shop_order.dart';
import '../../shared/config/app_config.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/widgets/demo_banner.dart';

class ReturnRequestScreen extends StatefulWidget {
  final AppContainer container;
  final ShopOrder order;

  const ReturnRequestScreen({
    super.key,
    required this.container,
    required this.order,
  });

  @override
  State<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends State<ReturnRequestScreen> {
  final _reason = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _submitted = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reason.text.trim().isEmpty) {
      setState(() => _error = 'Please describe why you are returning this order');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.container.storeRepository.requestReturn(
        orderId: widget.order.id,
        reason: _reason.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _submitted = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request return')),
      body: Column(
        children: [
          const DemoBanner(message: 'Returns within ${AppConfig.returnWindowDays} days of delivery'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Order ${widget.order.id}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text('Total: R${widget.order.total.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                QuietNotice(
                  message:
                      'You may request a return within ${AppConfig.returnWindowDays} days '
                      'of delivery if the item is unused and in original packaging.',
                ),
                const SizedBox(height: 16),
                if (_submitted) ...[
                  const Icon(Icons.check_circle, color: DigititanColors.teal, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Return request submitted',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Digititan support will review your request. '
                    'Never pay cash to individuals for refunds.',
                  ),
                ] else ...[
                  TextField(
                    controller: _reason,
                    decoration: const InputDecoration(
                      labelText: 'Reason for return',
                      hintText: 'Unused, wrong size, defective…',
                    ),
                    maxLines: 4,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: DigititanColors.danger)),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: Text(_loading ? 'Submitting…' : 'Submit return request'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
