import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../infrastructure/dummy/demo_hub.dart';
import '../../shared/theme/digititan_theme.dart';
import '../../shared/widgets/demo_banner.dart';

/// Simple ambassador hat — official promoter view after Ops approval.
class AmbassadorShell extends StatelessWidget {
  final AppContainer container;
  final User user;
  final VoidCallback onLogout;
  final ValueChanged<AppHat>? onSwitchHat;
  final ValueChanged<User>? onDemoUserSwitched;

  const AmbassadorShell({
    super.key,
    required this.container,
    required this.user,
    required this.onLogout,
    this.onSwitchHat,
    this.onDemoUserSwitched,
  });

  @override
  Widget build(BuildContext context) {
    final app = DemoHub.instance.approvedAmbassador(user.email);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambassador'),
        actions: [
          TextButton(
            onPressed: onLogout,
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const DemoBanner(
            message: 'Official ambassador · programme promoter (not a reseller)',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.verified_outlined, color: DigititanColors.teal),
              const SizedBox(width: 8),
              Text(
                'Approved',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
          Text(user.email, style: Theme.of(context).textTheme.bodySmall),
          if (app != null) ...[
            const SizedBox(height: 8),
            Text('Phone: ${app.phone}'),
            const SizedBox(height: 12),
            Text('Motivation', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(app.motivation, style: const TextStyle(height: 1.4)),
          ],
          const SizedBox(height: 20),
          QuietNotice(
            message:
                'Never ask anyone to pay cash to you. Buyers verify legitimacy '
                'through Digititan / Village NetAcad channels only.',
          ),
          const SizedBox(height: 24),
          if (onSwitchHat != null) ...[
            OutlinedButton(
              onPressed: () => onSwitchHat!(AppHat.customer),
              child: const Text('Switch to Customer app'),
            ),
            if (DemoHub.instance.isApprovedReseller(user.email)) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => onSwitchHat!(AppHat.reseller),
                child: const Text('Switch to Reseller dashboard'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
