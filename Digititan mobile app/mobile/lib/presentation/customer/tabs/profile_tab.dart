import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/user.dart';
import '../../../shared/config/app_config.dart';
import '../../../shared/widgets/demo_banner.dart';
import '../my_orders_screen.dart';

class ProfileTab extends StatelessWidget {
  final AppContainer container;
  final User user;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.container,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          const DemoBanner(
            message:
                'Switch roles: Logout → Sign in as Customer / Reseller / Admin.',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                  Text(user.email),
                  Text('Role: ${user.role.name}'),
                  const SizedBox(height: 16),
                  Text('Demo cheat sheet', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Email OTP: ${AppConfig.emailOtpDemo}\n'
                    'Payment OTP: ${AppConfig.paymentOtpDemo}\n'
                    'Store website: ${AppConfig.digititanStoreUrl}\n'
                    'Password for all demo accounts: demo123',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pillars: Training · Academies · Store\n'
                    'Shopping production path = website (samples in-app).\n'
                    'Donations: out of scope.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MyOrdersScreen(
                            container: container,
                            user: user,
                          ),
                        ),
                      );
                    },
                    child: const Text('My orders'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: onLogout,
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
