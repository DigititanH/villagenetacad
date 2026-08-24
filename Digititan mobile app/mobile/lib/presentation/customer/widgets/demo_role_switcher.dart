import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/user.dart';
import '../../../shared/config/app_config.dart';
import '../../../shared/theme/digititan_theme.dart';

/// Deck-only helper: jump between seeded demo accounts without retyping.
class DemoRoleSwitcher extends StatelessWidget {
  final AppContainer container;
  final ValueChanged<User> onSwitched;

  const DemoRoleSwitcher({
    super.key,
    required this.container,
    required this.onSwitched,
  });

  static const _accounts = <({String label, String email})>[
    (label: 'Customer', email: 'customer@demo.com'),
    (label: 'Reseller', email: 'reseller@demo.com'),
    (label: 'Ops Admin', email: 'ops@demo.com'),
    (label: 'Super Admin', email: 'super@demo.com'),
  ];

  Future<void> _switchTo(BuildContext context, String email) async {
    try {
      await container.authRepository.signOut();
      final user = await container.authRepository.signInWithEmail(
        email: email,
        password: 'demo123',
      );
      onSwitched(user);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Switched to $email')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: DigititanColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          'Demo role switch (decks only)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          'Password for all: demo123 · ${AppConfig.demoModeLine}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          for (final a in _accounts)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(a.label),
              subtitle: Text(a.email),
              trailing: const Icon(Icons.swap_horiz),
              onTap: () => _switchTo(context, a.email),
            ),
        ],
      ),
    );
  }
}
