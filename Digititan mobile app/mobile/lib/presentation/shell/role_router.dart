import 'package:flutter/material.dart';

import '../../app/injection.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../admin/admin_shell.dart';
import '../customer/customer_shell.dart';
import '../reseller/reseller_shell.dart';

class RoleRouter extends StatelessWidget {
  final AppContainer container;
  final User user;
  final VoidCallback onLogout;
  final ValueChanged<User>? onDemoUserSwitched;

  const RoleRouter({
    super.key,
    required this.container,
    required this.user,
    required this.onLogout,
    this.onDemoUserSwitched,
  });

  @override
  Widget build(BuildContext context) {
    switch (user.role) {
      case UserRole.customer:
        return CustomerShell(
          container: container,
          user: user,
          onLogout: onLogout,
          onDemoUserSwitched: onDemoUserSwitched,
        );
      case UserRole.reseller:
        return ResellerShell(
          container: container,
          user: user,
          onLogout: onLogout,
          onDemoUserSwitched: onDemoUserSwitched,
        );
      case UserRole.opsAdmin:
      case UserRole.superAdmin:
        return AdminShell(
          container: container,
          user: user,
          onLogout: onLogout,
          onDemoUserSwitched: onDemoUserSwitched,
        );
    }
  }
}
