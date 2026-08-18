import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import 'payment_otp_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final AppContainer container;
  final User user;

  const CheckoutScreen({
    super.key,
    required this.container,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final total = container.storeRepository.cartTotal();
    final lines = container.storeRepository.getCart();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Buyer: ${user.name}'),
            Text(user.email),
            const SizedBox(height: 12),
            Text('${lines.length} line(s) · Total R${total.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            const Text(
              'Payment note (prototype):\n'
              '1) Simulate payment gateway\n'
              '2) Confirm with email OTP (meeting security story)\n'
              '3) Create order + tracking\n\n'
              'Real PayFast/gateway comes later. OTP for this demo = 654321',
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                container.storeRepository.startPaymentOtp(user.email);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PaymentOtpScreen(
                      container: container,
                      user: user,
                    ),
                  ),
                );
              },
              child: const Text('Pay (simulated gateway)'),
            ),
          ],
        ),
      ),
    );
  }
}
