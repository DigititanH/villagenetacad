import 'package:flutter/material.dart';

import '../../shared/theme/digititan_theme.dart';

/// Shown after a reseller applies and must wait for Ops Admin approval.
/// Same pattern as [AccountDeactivatedScreen] — dedicated page, not inline form noise.
class ResellerPendingApprovalScreen extends StatelessWidget {
  final String email;

  const ResellerPendingApprovalScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Awaiting approval')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.hourglass_top_outlined,
              size: 56,
              color: DigititanColors.primary,
            ),
            const SizedBox(height: 18),
            Text(
              'Reseller application submitted',
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
              'Your account was created. An Ops Admin must approve it before '
              'you can sign in on the app or the website.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 14),
            Text(
              'You will be able to sign in with this email and password once '
              'approval is complete.',
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
