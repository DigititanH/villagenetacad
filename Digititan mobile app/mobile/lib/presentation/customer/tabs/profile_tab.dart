import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/user.dart';
import '../../../shared/config/app_config.dart';
import '../../../shared/theme/digititan_theme.dart';
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: DigititanColors.primaryDark,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(user.email, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            user.role.label,
            style: const TextStyle(
              color: DigititanColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
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
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onLogout,
            child: const Text('Logout'),
          ),
          const SizedBox(height: 20),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                'Demo reference',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email OTP: ${AppConfig.emailOtpDemo}\n'
                    'Payment OTP: ${AppConfig.paymentOtpDemo}\n'
                    'Password: demo123\n'
                    'Store: ${AppConfig.digititanStoreUrl}',
                    style: Theme.of(context).textTheme.bodySmall,
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
