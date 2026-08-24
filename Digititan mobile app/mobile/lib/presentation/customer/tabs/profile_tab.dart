import 'package:flutter/material.dart';

import '../../../app/injection.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/enums/user_role.dart';
import '../../../infrastructure/dummy/demo_hub.dart';
import '../../../shared/config/app_config.dart';
import '../../../shared/theme/digititan_theme.dart';
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
  final ValueChanged<User>? onDemoUserSwitched;
  final ValueChanged<AppHat>? onSwitchHat;

  const ProfileTab({
    super.key,
    required this.container,
    required this.user,
    required this.onLogout,
    this.onDemoUserSwitched,
    this.onSwitchHat,
  });

  @override
  Widget build(BuildContext context) {
    final hub = DemoHub.instance;
    final approvedReseller = hub.isApprovedReseller(user.email);
    final pendingReseller =
        hub.resellerProfiles[user.email.toLowerCase()]?.isPending == true;
    final approvedAmbassador = hub.isApprovedAmbassador(user.email);

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
            'Customer',
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
                  const Chip(
                    avatar: Icon(Icons.storefront_outlined, size: 18),
                    label: Text('Approved reseller'),
                  ),
                if (approvedAmbassador)
                  const Chip(
                    avatar: Icon(Icons.verified_outlined, size: 18),
                    label: Text('Approved ambassador'),
                  ),
              ],
            ),
          ],
          if (onSwitchHat != null && approvedReseller) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () {
                onSwitchHat!(AppHat.reseller);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Switched to Reseller dashboard')),
                );
              },
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Switch to Reseller dashboard'),
            ),
          ],
          if (onSwitchHat != null && approvedAmbassador) ...[
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () {
                onSwitchHat!(AppHat.ambassador);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Switched to Ambassador view')),
                );
              },
              icon: const Icon(Icons.campaign_outlined),
              label: const Text('Switch to Ambassador view'),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DigititanColors.softBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DigititanColors.muted),
              ),
              child: Text(
                'Reseller application under review — waiting for Ops Admin.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          if (!approvedAmbassador) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AmbassadorApplyScreen(user: user),
                  ),
                );
              },
              child: const Text('Become an Ambassador'),
            ),
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
          if (onDemoUserSwitched != null) ...[
            const SizedBox(height: 20),
            DemoRoleSwitcher(
              container: container,
              onSwitched: onDemoUserSwitched!,
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
