import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/shop_order.dart';
import '../../shared/theme/digititan_theme.dart';

class ReviewOrderScreen extends StatefulWidget {
  final AppContainer container;
  final ShopOrder order;

  const ReviewOrderScreen({
    super.key,
    required this.container,
    required this.order,
  });

  @override
  State<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  int _stars = 5;
  final _text = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _submitted = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.container.storeRepository.submitReview(
        orderId: widget.order.id,
        stars: _stars,
        text: _text.text.trim(),
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
      appBar: AppBar(title: const Text('Review order')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Order ${widget.order.id}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          if (_submitted) ...[
            const Icon(Icons.star, color: DigititanColors.accent, size: 48),
            const SizedBox(height: 8),
            Text(
              'Thank you for your review!',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('You rated this order $_stars / 5 stars.'),
          ] else ...[
            Text('How was your order?', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                final star = i + 1;
                return IconButton(
                  onPressed: () => setState(() => _stars = star),
                  icon: Icon(
                    star <= _stars ? Icons.star : Icons.star_border,
                    color: DigititanColors.accent,
                    size: 36,
                  ),
                );
              }),
            ),
            TextField(
              controller: _text,
              decoration: const InputDecoration(
                labelText: 'Your review (optional)',
                hintText: 'Delivery, product quality, support…',
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
              child: Text(_loading ? 'Submitting…' : 'Submit review'),
            ),
          ],
        ],
      ),
    );
  }
}
