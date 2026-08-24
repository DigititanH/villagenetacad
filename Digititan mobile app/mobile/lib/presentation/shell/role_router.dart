import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../admin/admin_shell.dart';
import '../ambassador/ambassador_shell.dart';
import '../customer/customer_shell.dart';
import '../reseller/reseller_shell.dart';

class RoleRouter extends StatelessWidget {
  final AppContainer container;
  final User user;
  /// Which hat this person is wearing (customer / reseller / ambassador).
  final AppHat activeHat;
  final VoidCallback onLogout;
  final ValueChanged<AppHat>? onSwitchHat;
  final ValueChanged<User>? onDemoUserSwitched;

  const RoleRouter({
    super.key,
    required this.container,
    required this.user,
    required this.activeHat,
    required this.onLogout,
    this.onSwitchHat,
    this.onDemoUserSwitched,
  });

  @override
  Widget build(BuildContext context) {
    // Admins always stay in admin shells (demo switch still changes account).
    if (user.role.isAdmin) {
      return AdminShell(
        container: container,
        user: user,
        onLogout: onLogout,
        onDemoUserSwitched: onDemoUserSwitched,
      );
    }

    switch (activeHat) {
      case AppHat.reseller:
        return ResellerShell(
          container: container,
          user: user,
          onLogout: onLogout,
          onDemoUserSwitched: onDemoUserSwitched,
          onSwitchHat: onSwitchHat,
        );
      case AppHat.ambassador:
        return AmbassadorShell(
          container: container,
          user: user,
          onLogout: onLogout,
          onDemoUserSwitched: onDemoUserSwitched,
          onSwitchHat: onSwitchHat,
        );
      case AppHat.customer:
        return CustomerShell(
          container: container,
          user: user,
          onLogout: onLogout,
          onDemoUserSwitched: onDemoUserSwitched,
          onSwitchHat: onSwitchHat,
        );
    }
  }
}
