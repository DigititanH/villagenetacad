import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../shared/config/app_config.dart';
import '../../shared/result/result.dart';
import '../auth/otp_channel_picker.dart';
import 'order_detail_screen.dart';

class PaymentOtpScreen extends StatefulWidget {
  final AppContainer container;
  final User user;
  final String? referralCode;

  const PaymentOtpScreen({
    super.key,
    required this.container,
    required this.user,
    this.referralCode,
  });

  @override
  State<PaymentOtpScreen> createState() => _PaymentOtpScreenState();
}

class _PaymentOtpScreenState extends State<PaymentOtpScreen> {
  final _otp = TextEditingController(text: '654321');
  OtpChannel _channel = OtpChannel.email;
  bool _loading = false;
  String? _error;

  Future<void> _confirm() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await widget.container.placeOrder(
      buyerEmail: widget.user.email,
      buyerName: widget.user.name,
      otp: _otp.text,
      referralCode: widget.referralCode,
    );

    setState(() => _loading = false);

    switch (result) {
      case Success(:final data):
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(
              container: widget.container,
              orderId: data.id,
              justPlaced: true,
            ),
          ),
          (route) => route.isFirst,
        );
      case Failure(:final message):
        setState(() => _error = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${AppConfig.paymentGatewayName} step complete (prototype).\n'
              'Confirm payment for ${widget.user.email}',
            ),
            const SizedBox(height: 12),
            OtpChannelPicker(
              value: _channel,
              onChanged: (c) => setState(() => _channel = c),
              phoneHint: 'demo phone on file',
            ),
            const SizedBox(height: 8),
            Text(
              'Payment confirmation OTP: ${AppConfig.paymentOtpDemo}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextField(
              controller: _otp,
              decoration: const InputDecoration(labelText: 'OTP'),
              keyboardType: TextInputType.number,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _confirm,
              child: Text(_loading ? 'Confirming...' : 'Confirm payment'),
            ),
          ],
        ),
      ),
    );
  }
}
