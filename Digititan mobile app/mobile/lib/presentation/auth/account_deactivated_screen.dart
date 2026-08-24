import 'package:flutter/material.dart';

import '../../shared/theme/digititan_theme.dart';

/// Shown after a successful credential check fails because Ops deactivated the account.
class AccountDeactivatedScreen extends StatelessWidget {
  final String email;

  const AccountDeactivatedScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account locked')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 18),
            Text(
              'This account is deactivated',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              email,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: DigititanColors.foreground.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'You cannot sign in until an Ops Admin unlocks your account, '
              'or Digititan restores access.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 14),
            Text(
              'If you believe this was a mistake, contact Digititan support '
              'and ask them to reactivate your Village NetAcad account.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
