import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/reseller.dart';
import '../../domain/entities/user.dart';
import '../../infrastructure/dummy/demo_hub.dart';
import '../../infrastructure/dummy/dummy_store_repository.dart';
import '../../shared/config/app_config.dart';
import 'payment_otp_screen.dart';
import 'verify_reseller_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final AppContainer container;
  final User user;

  const CheckoutScreen({
    super.key,
    required this.container,
    required this.user,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final TextEditingController _code;
  String? _codeHint;

  @override
  void initState() {
    super.initState();
    final saved =
        DemoHub.instance.customerReferralCodes[widget.user.email.toLowerCase()];
    _code = TextEditingController(text: saved ?? '');
    if (saved != null) {
      final issued = DemoHub.instance.findCode(saved);
      _codeHint = issued == null
          ? null
          : 'Saved code: ${issued.code} (${issued.type.label} — ${issued.resellerName})';
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _applyCode() {
    final store = widget.container.storeRepository;
    if (store is! DummyStoreRepository) {
      setState(() => _codeHint = 'Code apply available in prototype store only');
      return;
    }
    final applied = store.saveReferralCode(widget.user.email, _code.text);
    setState(() {
      if (applied == null) {
        _codeHint = 'Invalid or inactive reseller code';
      } else {
        final issued = DemoHub.instance.findCode(applied)!;
        _codeHint =
            'Applied ${issued.code} (${issued.type.label}) — ${issued.resellerName}';
        _code.text = applied;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.container.storeRepository.cartTotal();
    final lines = widget.container.storeRepository.getCart();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Buyer: ${widget.user.name}'),
            Text(widget.user.email),
            const SizedBox(height: 12),
            Text('${lines.length} line(s) · Total R${total.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            Text(
              'Reseller referral code',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _code,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'e.g. VNA-B-LERATO or VNA-C-...',
                      hintText: 'Centre = VNA-C-* · Beneficiary = VNA-B-*',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _applyCode,
                  child: const Text('Apply'),
                ),
              ],
            ),
            if (_codeHint != null) ...[
              const SizedBox(height: 8),
              Text(_codeHint!, style: const TextStyle(fontSize: 12)),
            ],
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VerifyResellerScreen(
                      initialCode: _code.text.trim().isEmpty
                          ? null
                          : _code.text.trim(),
                    ),
                  ),
                );
              },
              child: const Text('Verify this reseller is legit'),
            ),
            const SizedBox(height: 8),
            Text(
              'Payment (Phase 3):\n'
              '• Same gateway story as Village NetAcad shop: ${AppConfig.paymentGatewayName}\n'
              '• Confirm with OTP ${AppConfig.paymentOtpDemo} (email or SMS)\n'
              '• Commission attributed to the referral code automatically\n'
              '• Never pay cash to individuals or ambassadors',
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_code.text.trim().isNotEmpty) {
                  _applyCode();
                }
                widget.container.storeRepository.startPaymentOtp(widget.user.email);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PaymentOtpScreen(
                      container: widget.container,
                      user: widget.user,
                      referralCode: _code.text.trim().isEmpty
                          ? null
                          : _code.text.trim().toUpperCase(),
                    ),
                  ),
                );
              },
              child: Text('Pay with ${AppConfig.paymentGatewayName}'),
            ),
          ],
        ),
      ),
    );
  }
}
