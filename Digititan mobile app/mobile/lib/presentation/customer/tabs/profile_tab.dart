import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/enums/user_role.dart';
import '../../../shared/config/app_config.dart';
import '../../../shared/theme/digititan_theme.dart';
import '../../../shared/utils/approved_role_switch.dart';
import '../ambassador_apply_screen.dart';
import '../become_reseller_screen.dart';
import '../legal_hub_screen.dart';
import '../my_orders_screen.dart';
import '../notifications_screen.dart';
import '../verify_reseller_screen.dart';
import '../widgets/demo_role_switcher.dart';

class ProfileTab extends StatelessWidget {
  final AppContainer container;
  final User user;
  final VoidCallback onLogout;
  /// Updates the live session user (demo switch + approved Customer↔Reseller).
  final ValueChanged<User>? onSessionUserChanged;

  const ProfileTab({
    super.key,
    required this.container,
    required this.user,
    required this.onLogout,
    this.onSessionUserChanged,
  });

  @override
  Widget build(BuildContext context) {
    final approvedReseller = ApprovedRoleSwitch.isApprovedReseller(user.email);
    final pendingReseller = ApprovedRoleSwitch.isPendingReseller(user.email);
    final approvedAmbassador =
        ApprovedRoleSwitch.isApprovedAmbassador(user.email);

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
          if (approvedReseller || approvedAmbassador) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (approvedReseller)
                  Chip(
                    avatar: const Icon(Icons.storefront_outlined, size: 18),
                    label: const Text('Approved reseller'),
                  ),
                if (approvedAmbassador)
                  Chip(
                    avatar: const Icon(Icons.verified_outlined, size: 18),
                    label: const Text('Approved ambassador'),
                  ),
              ],
            ),
          ],
          if (approvedReseller &&
              user.role == UserRole.customer &&
              onSessionUserChanged != null) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () {
                onSessionUserChanged!(
                  ApprovedRoleSwitch.asRole(user, UserRole.reseller),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Switched to Reseller view')),
                );
              },
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Switch to Reseller view'),
            ),
          ],
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
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NotificationsScreen(user: user),
                ),
              );
            },
            child: const Text('Notifications'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const VerifyResellerScreen(),
                ),
              );
            },
            child: const Text('Verify a reseller'),
          ),
          if (user.role == UserRole.customer) ...[
            if (!approvedReseller && !pendingReseller) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BecomeResellerScreen(
                        container: container,
                        user: user,
                      ),
                    ),
                  );
                },
                child: const Text('Become a Reseller'),
              ),
            ],
            if (pendingReseller) ...[
              const SizedBox(height: 10),
              const QuietPendingNotice(
                message: 'Reseller application under review — waiting for Ops Admin.',
              ),
            ],
            if (!approvedAmbassador) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AmbassadorApplyScreen(),
                    ),
                  );
                },
                child: const Text('Become an Ambassador'),
              ),
            ],
          ],
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LegalHubScreen(),
                ),
              );
            },
            child: const Text('Legal & privacy'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onLogout,
            child: const Text('Logout'),
          ),
          if (onSessionUserChanged != null) ...[
            const SizedBox(height: 20),
            DemoRoleSwitcher(
              container: container,
              onSwitched: onSessionUserChanged!,
            ),
          ],
          const SizedBox(height: 20),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                'Demo tips',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              childrenPadding: const EdgeInsets.only(bottom: 8),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Verify reseller: VNA-B-LERATO\n'
                    'Shop: ${AppConfig.villageNetAcadShopUrl}\n'
                    'Email/SMS OTP: ${AppConfig.emailOtpDemo}\n'
                    'Payment OTP: ${AppConfig.paymentOtpDemo}',
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

class QuietPendingNotice extends StatelessWidget {
  final String message;

  const QuietPendingNotice({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DigititanColors.softBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DigititanColors.muted),
      ),
      child: Text(message, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
